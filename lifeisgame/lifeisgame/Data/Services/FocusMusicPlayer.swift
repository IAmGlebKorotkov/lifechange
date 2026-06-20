//
//  FocusMusicPlayer.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import AVFoundation
import UIKit

protocol FocusMusicPlaying {
    func play(_ playlist: FocusMusicPlaylist) throws
    func stop()
}

enum FocusMusicPlaybackError: LocalizedError {
    case assetNotFound(String)

    var errorDescription: String? {
        switch self {
        case .assetNotFound(let name):
            return "Не удалось найти аудио-ассет: \(name)"
        }
    }
}

final class FocusMusicPlayer: NSObject, FocusMusicPlaying {
    static let shared = FocusMusicPlayer()

    private var playlist: FocusMusicPlaylist?
    private var currentTrackIndex = 0
    private var player: AVAudioPlayer?
    private var shouldContinuePlayback = false

    override private init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    func play(_ playlist: FocusMusicPlaylist) throws {
        stop(deactivateSession: false)
        guard !playlist.isSilent else { return }

        self.playlist = playlist
        currentTrackIndex = 0
        shouldContinuePlayback = true

        try configureAudioSession()
        try playCurrentTrack()
    }

    func stop() {
        stop(deactivateSession: true)
    }

    private func stop(deactivateSession: Bool) {
        shouldContinuePlayback = false
        player?.stop()
        player = nil
        playlist = nil
        currentTrackIndex = 0

        if deactivateSession {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }

    private func playCurrentTrack() throws {
        guard let playlist, !playlist.tracks.isEmpty else { return }

        let track = playlist.tracks[currentTrackIndex]
        guard let asset = dataAsset(named: track.assetName) else {
            throw FocusMusicPlaybackError.assetNotFound(track.assetName)
        }

        let nextPlayer = try AVAudioPlayer(data: asset.data)
        nextPlayer.delegate = self
        nextPlayer.prepareToPlay()
        nextPlayer.play()
        player = nextPlayer
    }

    private func dataAsset(named name: String) -> NSDataAsset? {
        let normalizedNames = [
            name,
            name.trimmingCharacters(in: .whitespacesAndNewlines),
            name.precomposedStringWithCanonicalMapping,
            name.decomposedStringWithCanonicalMapping
        ]

        let candidates = normalizedNames + normalizedNames.map { "music/\($0)" }
        for candidate in candidates {
            if let asset = NSDataAsset(name: candidate) {
                return asset
            }
        }
        return nil
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard
            let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return }

        switch type {
        case .began:
            player?.pause()
        case .ended:
            guard shouldContinuePlayback else { return }
            try? configureAudioSession()
            player?.play()
        @unknown default:
            break
        }
    }
}

extension FocusMusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard shouldContinuePlayback, let playlist, !playlist.tracks.isEmpty else { return }
        currentTrackIndex = (currentTrackIndex + 1) % playlist.tracks.count
        try? playCurrentTrack()
    }
}
