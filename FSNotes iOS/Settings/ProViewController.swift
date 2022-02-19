//
//  ProViewController.swift
//  FSNotes iOS
//
//  Created by Александр on 19.02.2022.
//  Copyright © 2022 Oleksandr Glushchenko. All rights reserved.
//

import UIKit
import NightNight

class ProViewController: UITableViewController {
    private var sections = [
        NSLocalizedString("General", comment: "Settings"),
    ]

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    private var rows: [String] = [
        NSLocalizedString("Default Keyboard In Editor", comment: ""),
        NSLocalizedString("Use Inline Tags", comment: ""),
        NSLocalizedString("Auto Versioning", comment: "")
    ]

    override func viewDidLoad() {
        view.mixedBackgroundColor = MixedColor(normal: 0xffffff, night: 0x000000)

        self.navigationItem.leftBarButtonItem = Buttons.getBack(target: self, selector: #selector(cancel))

        self.title = NSLocalizedString("Pro", comment: "Settings")
        super.viewDidLoad()
    }

    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(LanguageViewController(), animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uiSwitch = UISwitch()
        uiSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)

        let cell = UITableViewCell()
        cell.textLabel?.text = rows[indexPath.row]

        let view = UIView()
        view.mixedBackgroundColor = MixedColor(normal: 0xe2e5e4, night: 0x686372)
        cell.selectedBackgroundView = view

        switch indexPath.row {
        case 1:
            cell.accessoryView = uiSwitch
            uiSwitch.isOn = UserDefaultsManagement.inlineTags
            break
        case 2:
            cell.accessoryView = uiSwitch
            uiSwitch.isOn = UserDefaultsManagement.autoVersioning
            break
        default:
            break
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.mixedBackgroundColor = MixedColor(normal: 0xffffff, night: 0x000000)
        cell.textLabel?.mixedTextColor = MixedColor(normal: 0x000000, night: 0xffffff)

        if indexPath.row == 0 {
            cell.accessoryType = .disclosureIndicator
        }
    }

    @objc public func switchValueDidChange(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell,
            let tableView = cell.superview as? UITableView,
            let indexPath = tableView.indexPath(for: cell) else { return }


        switch indexPath.row {
        case 1:
            guard let uiSwitch = cell.accessoryView as? UISwitch else { return }
            UserDefaultsManagement.inlineTags = uiSwitch.isOn

            let vc = UIApplication.getVC()
            if UserDefaultsManagement.inlineTags {
                vc.sidebarTableView.loadAllTags()
            } else {
                vc.sidebarTableView.unloadAllTags()
            }

            vc.resizeSidebar(withAnimation: true)

            UIApplication.getEVC().resetToolbar()
        case 2:
            guard let uiSwitch = cell.accessoryView as? UISwitch else { return }
             UserDefaultsManagement.autoVersioning = uiSwitch.isOn

             if !uiSwitch.isOn {
                 autoVersioningPrompt()
             }
        default:
            return
        }
    }

    private func autoVersioningPrompt() {
        let title = NSLocalizedString("History removing", comment: "")
        let message = NSLocalizedString("Do you want to remove history of all notes?", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            let revisions = Storage.shared().getRevisionsHistory()
            do {
                try FileManager.default.removeItem(at: revisions)
            } catch {
                print("History clear: \(error)")
            }

            self.dismiss(animated: true)
        })

        let cancel = NSLocalizedString("Cancel", comment: "")
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
