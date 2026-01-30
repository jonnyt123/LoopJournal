import Foundation
import SwiftUI
import PDFKit

class PDFExportService {
    static func export(entry: JournalEntry, completion: @escaping (URL?) -> Void) {
        let pdfMetaData = [
            kCGPDFContextCreator: "LoopJournal",
            kCGPDFContextAuthor: "LoopJournal User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LoopJournalEntry.pdf")
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                let ctx = context.cgContext
                // Mood-based gradient header
                let colors = entry.mood.gradientColors.map { $0.cgColor }
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0,1])!
                ctx.saveGState()
                ctx.addRect(CGRect(x: 0, y: 0, width: pageRect.width, height: 120))
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: pageRect.width, y: 120), options: [])
                ctx.restoreGState()
                // Mood emojis
                let emoji = entry.moodEmojis.joined(separator: " ")
                let emojiFont = UIFont.systemFont(ofSize: 44)
                let emojiAttr = [NSAttributedString.Key.font: emojiFont]
                (emoji as NSString).draw(at: CGPoint(x: 32, y: 32), withAttributes: emojiAttr)
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateStr = dateFormatter.string(from: entry.date)
                let dateFont = UIFont.systemFont(ofSize: 18, weight: .medium)
                let dateAttr = [NSAttributedString.Key.font: dateFont, .foregroundColor: UIColor.white]
                (dateStr as NSString).draw(at: CGPoint(x: 32, y: 90), withAttributes: dateAttr)
                // Note
                let noteFont = UIFont.systemFont(ofSize: 20)
                let noteAttr = [NSAttributedString.Key.font: noteFont]
                let noteRect = CGRect(x: 32, y: 150, width: pageRect.width - 64, height: 200)
                (entry.note as NSString).draw(in: noteRect, withAttributes: noteAttr)
                // Photo
                if let media = entry.media, case let .photo(imageName) = media, let uiImage = UIImage(named: imageName) {
                    let imgRect = CGRect(x: 32, y: 370, width: pageRect.width - 64, height: 220)
                    uiImage.draw(in: imgRect)
                }
            }
            completion(url)
        } catch {
            completion(nil)
        }
    }

    static func exportAll(entries: [JournalEntry], completion: @escaping (URL?) -> Void) {
        let pdfMetaData = [
            kCGPDFContextCreator: "LoopJournal",
            kCGPDFContextAuthor: "LoopJournal User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LoopJournalAllEntries.pdf")
        do {
            try renderer.writePDF(to: url) { context in
                for entry in entries {
                    context.beginPage()
                    let ctx = context.cgContext
                    let colors = entry.mood.gradientColors.map { $0.cgColor }
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0,1])!
                    ctx.saveGState()
                    ctx.addRect(CGRect(x: 0, y: 0, width: pageRect.width, height: 120))
                    ctx.clip()
                    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: pageRect.width, y: 120), options: [])
                    ctx.restoreGState()
                    let emoji = entry.moodEmojis.joined(separator: " ")
                    let emojiFont = UIFont.systemFont(ofSize: 44)
                    let emojiAttr = [NSAttributedString.Key.font: emojiFont]
                    (emoji as NSString).draw(at: CGPoint(x: 32, y: 32), withAttributes: emojiAttr)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let dateStr = dateFormatter.string(from: entry.date)
                    let dateFont = UIFont.systemFont(ofSize: 18, weight: .medium)
                    let dateAttr = [NSAttributedString.Key.font: dateFont, .foregroundColor: UIColor.white]
                    (dateStr as NSString).draw(at: CGPoint(x: 32, y: 90), withAttributes: dateAttr)
                    let noteFont = UIFont.systemFont(ofSize: 20)
                    let noteAttr = [NSAttributedString.Key.font: noteFont]
                    let noteRect = CGRect(x: 32, y: 150, width: pageRect.width - 64, height: 200)
                    (entry.note as NSString).draw(in: noteRect, withAttributes: noteAttr)
                    if let media = entry.media, case let .photo(imageName) = media, let uiImage = UIImage(named: imageName) {
                        let imgRect = CGRect(x: 32, y: 370, width: pageRect.width - 64, height: 220)
                        uiImage.draw(in: imgRect)
                    }
                }
            }
            completion(url)
        } catch {
            completion(nil)
        }
    }
}
