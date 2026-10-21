//
//  AvatarStore.swift
//  lifeisgame
//
//  Хранение аватарки пользователя на диске (Documents/avatars).
//

import UIKit

final class AvatarStore {

    static let shared = AvatarStore()

    private init() {}

    private var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("avatars", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func fileURL(for userID: UUID) -> URL {
        directory.appendingPathComponent("\(userID.uuidString).jpg")
    }

    func loadAvatar(for userID: UUID) -> UIImage? {
        UIImage(contentsOfFile: fileURL(for: userID).path)
    }

    /// Ресайз и кодирование JPEG — тяжёлые операции для фото с камеры (12+ МП),
    /// выполняются в фоне; completion приходит на главный поток с готовой картинкой.
    func saveAvatar(_ image: UIImage, for userID: UUID, completion: @escaping (UIImage?) -> Void) {
        let url = fileURL(for: userID)

        DispatchQueue.global(qos: .userInitiated).async {
            let squared = image.squareFilled(side: 400)
            if let data = squared.jpegData(compressionQuality: 0.85) {
                try? data.write(to: url, options: .atomic)
            }

            DispatchQueue.main.async {
                completion(squared)
            }
        }
    }

    func deleteAvatar(for userID: UUID) {
        try? FileManager.default.removeItem(at: fileURL(for: userID))
    }
}

private extension UIImage {

    /// Квадрат side×side с заполнением по короткой стороне (center crop).
    func squareFilled(side: CGFloat) -> UIImage {
        let minSide = min(size.width, size.height)
        guard minSide > 0 else { return self }

        let scaleFactor = side / minSide
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))

        return renderer.image { _ in
            draw(in: CGRect(
                x: (side - scaledSize.width) / 2,
                y: (side - scaledSize.height) / 2,
                width: scaledSize.width,
                height: scaledSize.height
            ))
        }
    }
}
