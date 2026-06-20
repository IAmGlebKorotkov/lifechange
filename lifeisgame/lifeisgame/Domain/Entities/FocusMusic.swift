//
//  FocusMusic.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import Foundation

struct FocusMusicTrack: Equatable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let assetName: String
}

struct FocusMusicPlaylist: Equatable, Identifiable {
    let id: String
    let title: String
    let tracks: [FocusMusicTrack]

    var isSilent: Bool {
        tracks.isEmpty
    }
}

enum FocusMusicLibrary {
    static let silentPlaylistID = "silent"

    private static let load = FocusMusicTrack(
        id: "load-140",
        title: "022 Load",
        artist: "116huncho",
        assetName: "022load140f#m_116huncho"
    )

    private static let thoughts = FocusMusicTrack(
        id: "thoughts-138",
        title: "Мысли",
        artist: "Липвэй",
        assetName: "мысли 138 липвэй"
    )

    private static let mainstorm = FocusMusicTrack(
        id: "mainstorm-149",
        title: "Mainstorm",
        artist: "116huncho, Nyvice",
        assetName: "MAINSTORM 149BPM D#MIN 116HUNCHO NYVICE"
    )

    private static let insideOut = FocusMusicTrack(
        id: "inside-out-140",
        title: "Наизнанку",
        artist: "Дэфф",
        assetName: "наизнанку 140 дэфф"
    )

    private static let nearby = FocusMusicTrack(
        id: "nearby-116",
        title: "Рядом",
        artist: "Липвэй",
        assetName: "рядом 116 липвэй"
    )

    private static let letter = FocusMusicTrack(
        id: "letter-144",
        title: "Письмо",
        artist: "Липвэй",
        assetName: "письмо 144 липвэй"
    )

    private static let flood = FocusMusicTrack(
        id: "flood-150",
        title: "Потоп",
        artist: "3д3ф3",
        assetName: "потоп 150 3д3ф3"
    )

    private static let redRose = FocusMusicTrack(
        id: "red-rose-141",
        title: "Алая роза",
        artist: "Аликслав",
        assetName: "алая роза 141 аликслав"
    )

    private static let rockBoy = FocusMusicTrack(
        id: "rock-boy-143",
        title: "Рокпацан",
        artist: "Дэфф",
        assetName: "рокпацан 143 дэфф "
    )

    private static let starter = FocusMusicTrack(
        id: "starter-147",
        title: "Стартер",
        artist: "Джи Мин, Дэфф",
        assetName: "стартер 147 джи мин дэфф"
    )

    private static let lady = FocusMusicTrack(
        id: "lady-148",
        title: "012 Lady",
        artist: "116huncho",
        assetName: "012lady148bm_116huncho"
    )

    private static let stayWithMe = FocusMusicTrack(
        id: "stay-with-me-160",
        title: "Побудь со мной",
        artist: "Липвэй",
        assetName: "побудь со мной 160 липвэй"
    )

    private static let mechanics = FocusMusicTrack(
        id: "mechanics-145",
        title: "Механика",
        artist: "STWX",
        assetName: "#МЕХАНИКА 145 BMINOR ##STWX @LOOP"
    )

    private static let sweetDreams = FocusMusicTrack(
        id: "sweet-dreams-147",
        title: "Сладких снов",
        artist: "Дэфф",
        assetName: "сладких снов 147 дэфф"
    )

    private static let blackStar = FocusMusicTrack(
        id: "black-star-143",
        title: "Черная звезда",
        artist: "Дэфф",
        assetName: "чернаязвезда битос 143 дэфф"
    )

    private static let justBeFriends = FocusMusicTrack(
        id: "just-be-friends-128",
        title: "Just Be Friends",
        artist: "Дэфф",
        assetName: "джаст би фрэндс 128 дэфф од"
    )

    private static let maison = FocusMusicTrack(
        id: "maison-140",
        title: "Maison",
        artist: "D3ff",
        assetName: "maison 140 d3ff"
    )

    private static let rockAunt = FocusMusicTrack(
        id: "rock-aunt-144",
        title: "Роктетя",
        artist: "Дэфф",
        assetName: "роктётя 144 дэфф"
    )

    private static let star = FocusMusicTrack(
        id: "star-119",
        title: "Star",
        artist: "116huncho",
        assetName: "STAR 119 A MIN 116HUNCHO"
    )

    private static let beYourself = FocusMusicTrack(
        id: "be-yourself-140",
        title: "Стань собой",
        artist: "ДФ",
        assetName: "стань собой 140 дф"
    )

    private static let deathstar = FocusMusicTrack(
        id: "deathstar-142",
        title: "Deathstar",
        artist: "Deffonfleek",
        assetName: "(LOOP) 025 DEATHSTAR 142 G#MIN DEFFONFLEEK"
    )

    static let playlists: [FocusMusicPlaylist] = [
        FocusMusicPlaylist(
            id: silentPlaylistID,
            title: "Без музыки",
            tracks: []
        ),
        FocusMusicPlaylist(
            id: "deep-focus",
            title: "Deep Focus",
            tracks: [load, star, lady, maison, thoughts, nearby]
        ),
        FocusMusicPlaylist(
            id: "lofi",
            title: "Lo-fi",
            tracks: [nearby, thoughts, letter, justBeFriends, redRose]
        ),
        FocusMusicPlaylist(
            id: "intense",
            title: "Интенсив",
            tracks: [mainstorm, mechanics, deathstar, starter, flood, rockBoy, blackStar, rockAunt]
        ),
        FocusMusicPlaylist(
            id: "evening",
            title: "Вечер",
            tracks: [sweetDreams, beYourself, insideOut, stayWithMe, maison]
        )
    ]
}
