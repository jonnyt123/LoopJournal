import SwiftUI
import CoreData

struct CoreDataTimelineView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday = true
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)],
        animation: .spring()
    ) private var entries: FetchedResults<JournalEntryEntity>
    
    @State private var showingAdd = false
    @State private var editingEntry: JournalEntryEntity?
    @State private var viewMode: ViewMode = .list
    @State private var selectedMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            let screenWidth = UIScreen.main.bounds.width
            let horizontalPadding: CGFloat = screenWidth < 380 ? 12 : 16
            Group {
                switch viewMode {
                case .list:
                    List {
                        ForEach(entries, id: \.objectID) { entry in
                            entryRow(entry)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEntry = entry }
                        }
                        .onDelete(perform: delete)
                    }
                case .month:
                    ScrollView {
                        VStack(spacing: 16) {
                            monthHeader
                            calendarGrid
                            dayEntriesSection
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Timeline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("View", selection: $viewMode) {
                        Text("Day").tag(ViewMode.list)
                        Text("Month").tag(ViewMode.month)
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditEntryView()
                    .environment(\.managedObjectContext, context)
            }
            .sheet(item: $editingEntry) { entry in
                AddEditEntryView(entry: entry)
                    .environment(\.managedObjectContext, context)
            }
        }
    }
    
    private var monthHeader: some View {
        let screenWidth = UIScreen.main.bounds.width
        return HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(selectedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: screenWidth < 380 ? 18 : 20, weight: .semibold, design: .rounded))
            Spacer()
            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.top, 8)
    }

    private var calendarGrid: some View {
        let days = daysInMonthGrid(for: selectedMonth)
        return VStack(spacing: 8) {
            HStack {
                ForEach(calendarShortWeekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(days.indices, id: \.self) { index in
                    calendarDayCell(days[index])
                }
            }
        }
    }

    private var dayEntriesSection: some View {
        let dayEntries = entriesForDay(selectedDate)
        let screenWidth = UIScreen.main.bounds.width
        return VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
                .font(.system(size: screenWidth < 380 ? 14 : 16, weight: .semibold))
            if dayEntries.isEmpty {
                Text("No entries for this day.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                ForEach(dayEntries, id: \.objectID) { entry in
                    entryRow(entry)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                }
            }
        }
    }

    private func entryRow(_ entry: JournalEntryEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.moodEmojisArray.joined(separator: " "))
                    .font(.largeTitle)
                Spacer()
                Text(entry.date ?? Date(), style: .date)
                    .font(.caption)
            }
            Text(entry.note ?? "")
                .font(.body)
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(12)
            }
        }
    }

    private func calendarDayCell(_ date: Date?) -> some View {
        let calendar = Calendar.current
        let isSelected = date != nil && calendar.isDate(date!, inSameDayAs: selectedDate)
        let hasEntry = date != nil && !entriesForDay(date!).isEmpty
        return Button(action: {
            if let date = date {
                selectedDate = date
            }
        }) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                    .frame(width: 34, height: 34)
                Text(date.map { String(calendar.component(.day, from: $0)) } ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(date == nil ? .clear : .primary)
                if hasEntry {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                        .offset(y: 14)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func shiftMonth(by offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: selectedMonth) {
            selectedMonth = newMonth
            if !Calendar.current.isDate(selectedDate, equalTo: newMonth, toGranularity: .month) {
                selectedDate = newMonth
            }
        }
    }

    private func entriesForDay(_ date: Date) -> [JournalEntryEntity] {
        let calendar = Calendar.current
        return entries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return calendar.isDate(entryDate, inSameDayAs: date)
        }
    }

    private func daysInMonthGrid(for month: Date) -> [Date?] {
        let calendar = calendarForSettings()
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthDays = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }
        let firstDay = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingBlankDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leadingBlankDays)
        for day in monthDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    private var calendarShortWeekdays: [String] {
        let calendar = calendarForSettings()
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private func calendarForSettings() -> Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = weekStartsOnMonday ? 2 : 1
        return calendar
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            CoreDataManager.shared.delete(entry)
        }
    }
}

private enum ViewMode: String {
    case list
    case month
}
