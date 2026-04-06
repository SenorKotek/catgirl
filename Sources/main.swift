import AppKit

private enum CatPose {
    case idleA
    case idleB
    case waveLeft
    case waveRight
    case excited

    var frame: [String] {
        switch self {
        case .idleA:
            return [
                #" /\_/\"#,
                "(=^.^=)",
                #" /|_|\"#
            ]
        case .idleB:
            return [
                #" /\_/\"#,
                "(=^o^=)",
                #" /|_|\"#
            ]
        case .waveLeft:
            return [
                #" /\_/\"#,
                "(=^.^=)ﾉ",
                #" /|_|\"#
            ]
        case .waveRight:
            return [
                #" /\_/\"#,
                "ヽ(=^.^=)",
                #" /|_|\"#
            ]
        case .excited:
            return [
                #" /\_/\"#,
                "(=^w^=)",
                #" /|o|\"#
            ]
        }
    }
}

final class DockCatAnimator {
    private let idleFrames: [CatPose] = [.idleA, .idleB]
    private let animationInterval: TimeInterval = 0.22

    private var idleIndex = 0
    private var waveQueue: [CatPose] = []
    private var timer: Timer?
    private var localMonitor: Any?
    private var globalMonitor: Any?

    func start() {
        NSApp.setActivationPolicy(.regular)

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.onKeyPress()
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] _ in
            self?.onKeyPress()
        }

        render(pose: idleFrames[idleIndex])

        timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    deinit {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
    }

    private func onKeyPress() {
        waveQueue += [.waveLeft, .waveRight, .excited, .waveRight, .waveLeft]
    }

    private func tick() {
        if !waveQueue.isEmpty {
            render(pose: waveQueue.removeFirst())
            return
        }

        idleIndex = (idleIndex + 1) % idleFrames.count
        render(pose: idleFrames[idleIndex])
    }

    private func render(pose: CatPose) {
        NSApp.applicationIconImage = makeIcon(from: pose.frame)
    }

    private func makeIcon(from lines: [String]) -> NSImage {
        let iconSize = NSSize(width: 256, height: 256)
        let image = NSImage(size: iconSize)

        image.lockFocus()
        defer { image.unlockFocus() }

        NSColor(calibratedWhite: 0.1, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: iconSize)).fill()

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 46, weight: .bold),
            .foregroundColor: NSColor.systemPink,
            .paragraphStyle: paragraph
        ]

        let text = lines.joined(separator: "\n")
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let textRect = NSRect(x: 0, y: 32, width: iconSize.width, height: iconSize.height - 64)
        attributed.draw(in: textRect)

        return image
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let animator = DockCatAnimator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        animator.start()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
