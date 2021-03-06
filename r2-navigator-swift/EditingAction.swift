//
//  EditingAction.swift
//  r2-navigator-swift
//
//  Created by Aferdita Muriqi, Mickaël Menu on 03.04.19.
//
//  Copyright 2019 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation
import UIKit
import R2Shared
import Translator
import PromiseKit
import PreferSetting

public enum EditingAction: String {
    case copy = "copy:"
    case share = "shareSelection:"
    case lookup = "_lookup:"
    case translate = "showFullTranslate:"
    case speak = "speak:"
    
    public static var defaultActions: [EditingAction] {
        return [copy, share, lookup, translate, speak]
    }
}

public enum EditingModel {
    case normal
    case translate
}


protocol EditingActionsControllerDelegate: AnyObject {
    
    func editingActionsDidPreventCopy(_ editingActions: EditingActionsController)
    
}


/// Handles the authorization and check of editing actions.
final class EditingActionsController {
    
    public weak var delegate: EditingActionsControllerDelegate?

    private let actions: [EditingAction]
    private let rights: UserRights
    
    public var model = EditingModel.normal

    init(actions: [EditingAction], rights: UserRights) {
        self.actions = actions
        self.rights = rights
    }

    func canPerformAction(_ action: Selector) -> Bool {

        if model == .translate {
            if action == Selector(EditingAction.translate.rawValue) || action == Selector(EditingAction.speak.rawValue) {
                return true
            }
            return false
        }
        
        
        for editingAction in self.actions {
            if action == Selector(editingAction.rawValue) || action == Selector(EditingAction.speak.rawValue) {
                if action == Selector(EditingAction.translate.rawValue ) || action == Selector(EditingAction.speak.rawValue) {
                    return false
                }
                return true
            }
        }
        return false
    }
    
    
    // MARK: - Selection
    
    /// Current user selection contents and frame in the publication view.
    var selection: (text: String, frame: CGRect)?
    
    /// Peeks into the available selection contents authorized for copy.
    /// To be used only when required to have the contents before actually using it (eg. Share dialog). To consume the actual copy, use `copy()`.
    var selectionAuthorizedForCopy: (text: String, frame: CGRect)? {
        guard
            let selection = selection,
            rights.canCopy(text: selection.text) else
        {
            return nil
        }
        
        return selection
    }
    
    /// To be called when the user selection changed.
    func selectionDidChange(_ selection: (text: String, frame: CGRect)?) {
        self.selection = selection
    }

    
    // MARK: - Copy

    /// Returns whether the copy interaction is at all allowed. It doesn't guarantee that the next copy action will be valid, if the license cancels it.
    var canCopy: Bool {
        return actions.contains(.copy) && rights.canCopy
    }

    /// Copies the authorized portion of the selection text into the pasteboard.
    func copy() {
        guard let text = selection?.text else {
            return
        }
        guard rights.copy(text: text) else {
            delegate?.editingActionsDidPreventCopy(self)
            return
        }
        
        UIPasteboard.general.string = text
    }
    
    // MARK: -
    
    func speak() {
        guard let text = selection?.text else {
            return
        }
        Translator.share.speak(text)
    }
    
    func showTranslat() {
        guard let text = selection?.text else {
            return
        }
        
//        let sourceLanguage = BookTranslateSetting.share.
        let targetLanguage = UserPreferSettings.share.defaultLanguage()
                
        firstly {
            Translator.share.translate(text: text, source: "en", target: targetLanguage, simple: false)
        }.done { translateText in
            print(translateText)
            let tvc = TranslationTextViewController()
            tvc.show(html: translateText)
            let nac  = UINavigationController(rootViewController: tvc)
            (self.delegate as? UIViewController)?.present(nac, animated: true, completion: nil)
            
        }.catch { error in
            print(error)
        }
        
    }
    
    
    // MARK: - Share
    
    /// Builds a UIActivityViewController to share the authorized contents of the user selection.
    func makeShareViewController(from contentsView: UIView) -> UIActivityViewController? {
        guard canCopy else {
            delegate?.editingActionsDidPreventCopy(self)
            return nil
        }
        guard let selection = selectionAuthorizedForCopy else {
            return nil
        }
        let viewController = UIActivityViewController(activityItems: [selection.text], applicationActivities: nil)
        viewController.completionWithItemsHandler = { _, completed, _, _ in
            if (completed) {
                self.copy()
            }
        }
        viewController.popoverPresentationController?.sourceView = contentsView
        viewController.popoverPresentationController?.sourceRect = selection.frame
        return viewController
    }
    
}
