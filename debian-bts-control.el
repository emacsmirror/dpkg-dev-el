;;; debian-bts-control.el --- Create messages for Debian BTS control interface

;; Copyright (C) 2003 Peter S Galbraith
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; debian-changelog-mode.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with your Debian installation, in /usr/share/common-licenses/GPL
;; If not, write to the Free Software Foundation, 675 Mass Ave,
;; Cambridge, MA 02139, USA.

;;; Commentary:
;; 
;;  Use `M-x debian-bts-control' to create an initial message, and
;;  `M-x debian-bts-control' again (or `C-c c') to insert new directives.

;;; Change log:
;;
;; V1.00 30apr2003  Peter S Galbraith <psg@debian.org>
;;  - Initial release.

;;; Code:
(require 'debian-bug)

(defcustom debian-bts-control-verbose-prompts-flag t
  "Non-nil means to be very verbose for `debian-bts-control' prompts."
  :group 'debian-bug
  :type 'boolean)

(defvar debian-bts-control-minor-mode nil)
(defvar debian-bts-control-minor-mode-map nil
  "Keymap for `debian-bts-control' minor mode.")
(if debian-bts-control-minor-mode-map
    nil
  (setq debian-bts-control-minor-mode-map (make-sparse-keymap))
  (define-key debian-bts-control-minor-mode-map "\C-cc" 'debian-bts-control))

(easy-menu-define debian-bts-control-menu debian-bts-control-minor-mode-map
  "Debian Bug Mode Menu"
  '("Control"
    ("Header"
     ["Custom From Address" (debian-bug--toggle-custom-From)
      :style toggle :active debian-bug-From-address
      :selected (debian-bug--is-custom-From)]
     "--"
     ["CC debian-devel" (debian-bug--toggle-CC-devel)
      :style toggle
      :selected (debian-bug--is-CC "debian-devel@lists.debian.org" "cc:")]
     ["CC me" (debian-bug--toggle-CC-myself)
      :style toggle :active debian-bug-From-address
      :selected (debian-bug--is-CC debian-bug-From-address "cc:")]
     )
     "--"
    ["Reassign" (debian-bts-control "reassign") t]
    ["Reopen" (debian-bts-control "reopen") t]
    ["Submitter" (debian-bts-control "submitter") t]
    ["Forwarded" (debian-bts-control "forwarded") t]
    ["NotForwarded" (debian-bts-control "notforwarded") t]
    ["Retitle" (debian-bts-control "retitle") t]
    ["Severity" (debian-bts-control "severity") t]
    ["Clone" (debian-bts-control "clone") t]
    ["Merge" (debian-bts-control "merge") t]
    ["UnMerge" (debian-bts-control "unmerge") t]
    ["Tags" (debian-bts-control "tags") t]
    ["Close" (debian-bts-control "close") t]
     "--"
    ("Web View"
     ["Bugs for a Package..." (debian-bug-web-bugs) t]
     ["Bug Number..." (debian-bug-web-bug) t]
     ["Package Info..." (debian-bug-web-packages) t]
     )
    ["Customize"
     (customize-group "debian-bug") (fboundp 'customize-group)]
    ("Help"
     ["Severities" (debian-bug-help-severity) t]
     ["Tags" (debian-bug-help-tags) t]
     ["Pseudo-Packages" (debian-bug-help-pseudo-packages) t]
;;   ["Addresses" (debian-bug-help-email) t]
     ["control commands" (debian-bts-help-control) t]
     )
    ))

(defvar debian-bts-control-font-lock-keywords
  '(("#.*$" .  font-lock-comment-face)
    ("^ *thank.*$" . font-lock-function-name-face)
    ("^ *\\(reassign\\) +\\(-?[0-9]+\\) +\\([a-z0-9\\.\\-]+\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-keyword-face nil t))
    ("^ *\\(reopen\\) +\\(-?[0-9]+\\) +\\(\\(!\\|=\\)\\|\\(.+\\)\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (4 font-lock-keyword-face nil t)
     (5 font-lock-string-face nil t))
    ("^ *\\(submitter\\) +\\(-?[0-9]+\\) +\\(\\(!\\)\\|\\(.+\\)\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (4 font-lock-keyword-face nil t)
     (5 font-lock-string-face nil t))
    ("^ *\\(forwarded\\) +\\(-?[0-9]+\\) +\\(.+\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-string-face))
    ("^ *\\(notforwarded\\) +\\(-?[0-9]+\\)"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face))
    ("^ *\\(retitle\\) +\\(-?[0-9]+\\) +\\(.+\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-string-face))
    ("^ *\\(severity\\) +\\(-?[0-9]+\\) +\\(\\(critical\\|grave\\|serious\\)\\|\\(important\\)\\|\\(normal\\)\\|\\(\\(minor\\)\\|\\(wishlist\\)\\)\\)"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (4 font-lock-warning-face nil t)
     (5 font-lock-keyword-name-face nil t)
     (6 font-lock-type-face nil t)
     (7 font-lock-string-face nil t))
    ("^ *\\(clone\\) +\\([0-9]+\\) +\\(-[0-9]+\\( +-[0-9]+\\)*\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-keyword-face))
    ("^ *\\(merge\\) +\\(-?[0-9]+ +-?[0-9]+\\( +-?[0-9]+\\)*\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-keyword-face))
    ("^ *\\(unmerge\\) +\\(-?[0-9]+\\)$"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face))
    ("^ *\\(tags\\) +\\(-?[0-9]+\\) +\\([-+=]? +\\)?\\(security\\)"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-keyword-face nil t)
     (4 font-lock-warning-face))
    ("^ *\\(tags\\) +\\(-?[0-9]+\\) +\\([-+=]? +\\)?\\(patch\\|wontfix\\|moreinfo\\|unreproducible\\|help\\|pending\\|fixed\\|upstream\\|potato\\|woody\\|sarge\\|sid\\)"
     (1 font-lock-function-name-face)
     (2 font-lock-type-face)
     (3 font-lock-keyword-face nil t)
     (4 font-lock-keyword-face))
    ("^ *\\(close\\) +\\(-?[0-9]+\\)$"
     (1 font-lock-warning-face)
     (2 font-lock-type-face)))
  "Regexp keywords to fontify `debian-bts-control' reports.")

(defun debian-bts-control-minor-mode (arg)
  "Toggle `debian-bts-control' mode.
A positive prefix argument ARG turns on `debian-bts-control' mode\;
a negative prefix argument turns it off.
\\<debian-bts-control-minor-mode-map>
\\[debian-bts-control]\t\tAdd a control command to the current message."
  (interactive "P")
  (set (make-local-variable 'debian-bts-control-minor-mode)
       (if arg
           (> (prefix-numeric-value arg) 0)
         (not debian-bts-control-minor-mode)))
  (cond
   (debian-bts-control-minor-mode                 ;Setup the minor-mode
    (if (fboundp 'font-lock-add-keywords)
        (font-lock-add-keywords nil debian-bts-control-font-lock-keywords t))
    )))

;; Install ourselves:
(or (assq 'debian-bts-control-minor-mode minor-mode-alist)
    (setq minor-mode-alist
          (cons '(debian-bts-control-minor-mode " DBugC") minor-mode-alist)))
(or (assq 'debian-bts-control-minor-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
          (cons (cons 'debian-bts-control-minor-mode
                      debian-bts-control-minor-mode-map)
                minor-mode-map-alist)))

(defvar debian-bts-control-alist
  '(("reassign") ("severity") ("reopen") ("submitter") ("forwarded")
    ("notforwarded") ("retitle") ("clone") ("merge") ("unmerge")
    ("tags") ("close"))
  "List of available commands at control@bugs.debian.org.")

(defun debian-bts-control (&optional action)
  "Contruct a message with initial ACTION command for control@bugs.debian.org.
Contructs a new control command line if called from within the message
being constructed."
  (interactive (list (completing-read "Command: "
                                      debian-bts-control-alist nil nil)))
  (when (not debian-bts-control-minor-mode)
    (reporter-compose-outgoing)
    (if (and (equal mail-user-agent 'gnus-user-agent)
             (string-equal " *nntpd*" (buffer-name)))
        (set-buffer "*mail*"))   ; Bug in emacs21.1?  Moves to " *nntpd*"
    (goto-char (point-min))
    (cond
     ((re-search-forward "To: " nil t)
      (insert "control@bugs.debian.org"))
     ((re-search-forward "To:" nil t)
      (insert " control@bugs.debian.org"))
     (t
      (insert "To: control@bugs.debian.org")))
    (if debian-bug-use-From-address
        (debian-bug--set-custom-From))
    (if debian-bug-always-CC-myself
        (debian-bug--set-CC debian-bug-From-address "cc:"))
    (goto-char (mail-header-end))
    (forward-line 1)
    (insert "thanks\n")
    (debian-bts-control-minor-mode 1))
  (goto-char (mail-header-end))
  (if (re-search-forward "^thank" nil t)
      (beginning-of-line)
    (goto-char (point-max)))
  (cond
   ((string-equal "reassign" action)
    (debian-bug-fill-packages-obarray)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "reassign bugnumber package

 Records that bug #BUGNUMBER is a bug in PACKAGE. This can be used to
 set the package if the user forgot the pseudo-header, or to change an
 earlier assignment. No notifications are sent to anyone (other than the
 usual information in the processing transcript).

"
                      ""
                     "Package to reassign to: "))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (package (completing-read
                     (concat verbose "Package to reassign to: ")
                     (debian-bug-fill-packages-obarray) nil nil)))
      (insert (format "reassign %s %s\n" bug-number package))))
   ((string-equal "reopen" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "reopen bugnumber [ originator-address | = | ! ]

 Reopens #BUGNUMBER if it is closed.

 By default, or if you specify =, the original submitter will remain the
 originator of the report.

 The originator will be set to the optional address you supply. If you wish
 to become the new originator of the reopened report you can use the !
 shorthand or specify your own email address.

 If the bug is not closed then \"reopen\" won't do anything, not even change
 the originator. To change the originator of an open bug report, use the
 \"submitter\" command; note that this will inform the original submitter of
 the change.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (originator (read-string
                        (concat verbose "Originator-address (optional): "))))
      (insert (format "reopen %s %s\n" bug-number originator))))
   ((string-equal "submitter" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "submitter bugnumber originator-address | !

 Changes the originator of #BUGNUMBER to ORIGINATOR-ADDRESS.

 If you wish to become the new originator of the report you can use the
 ! shorthand or specify your own email address.

 While the reopen command changes the originator of other bugs merged
 with the one being reopened, submitter does not affect merged bugs.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (originator (read-string
                        (concat verbose "Originator-address (optional): "))))
      (insert (format "submitter %s %s\n" bug-number originator))))
   ((string-equal "forwarded" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
"forwarded bugnumber address

 Notes that BUGNUMBER has been forwarded to the upstream maintainer at
 ADDRESS. This does not actually forward the report. This can be used to
 change an existing incorrect forwarded-to address, or to record a new
 one for a bug that wasn't previously noted as having been forwarded.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (address (read-string
                     (concat verbose "Forwarded-address: "))))
      (insert (format "forwarded %s %s\n" bug-number address))))
   ((string-equal "notforwarded" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "notforwarded bugnumber

 Forgets any idea that BUGNUMBER has been forwarded to any upstream
 maintainer. If the bug was not recorded as having been forwarded then
 this will do nothing.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: "))))
      (insert (format "notforwarded %s\n" bug-number))))
   ((string-equal "retitle" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "retitle bugnumber new-title

 Changes the TITLE of a bug report to that specified (the default is the
 Subject mail header from the original report).

 Unlike most of the other bug-manipulation commands, when used on one of
 a set of merged reports this will change the title of only the
 individual bug requested, and not all those with which it is merged.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (title (read-string
                     (concat verbose "New title: "))))
      (insert (format "retitle %s %s\n" bug-number title))))
   ((string-equal "severity" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "severity bugnumber severity

 Set the severity level for bug report #BUGNUMBER to SEVERITY. No
 notification is sent to the user who reported the bug.

 Severities are critical, grave, serious, important, normal, minor, and
 wishlist.

 For their meanings, consult the Control->Help->Severities menu.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (severity (completing-read "Severity: " debian-bug-severity-alist
                                      nil t)))
      (insert (format "severity %s %s\n" bug-number severity))))
   ((string-equal "clone" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "clone bugnumber [ new IDs ]

 Duplicate a bug report. Useful when a single report indicates that
 multiple distinct bugs have occured. \"New IDs\" are negative numbers,
 separated by spaces, which may be used in subsequent control commands to
 refer to the newly duplicated bugs.
   Example usage:
     clone 12345 -1 -2
     reassign -1 foo
     retitle -1 foo: foo sucks
     reassign -2 bar
     retitle -2 bar: bar sucks when used with foo
     severity -2 wishlist
"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (ids (read-string (concat verbose "New IDs (e.g. -1 -2): "))))
      (insert (format "clone %s %s\n" bug-number ids))))
   ((string-equal "merge" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "merge bugnumber bugnumber ...

 Merges two or more bug reports. When reports are merged, opening, closing,
 marking or unmarking as forwarded and reassigning any of the bugs to a new
 package will have an identical effect on all of the merged reports.

 Before bugs can be merged they must be in exactly the same state.

"
                      ""))
           (bug-numbers (read-string (concat verbose "All bug numbers: "))))
      (insert (format "merge %s\n" bug-numbers))))
   ((string-equal "unmerge" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
"unmerge bugnumber

 Disconnects a bug report from any other reports with which it may have
 been merged. If the report listed is merged with several others then
 they are all left merged with each other; only their associations with
 the bug explicitly named are removed.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: "))))
      (insert (format "unmerge %s\n" bug-number))))
   ((string-equal "tags" action)
    (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                        "tags bugnumber [ + | - | = ] tag

 Sets a particular tag for the bug report #BUGNUMBER to tag. No
 notification is sent to the user who reported the bug. + means adding, -
 means subtracting, and = means ignoring the current tags and setting them
 afresh. The default action is adding.

 Tags are patch, wontfix, moreinfo, unreproducible, help, pending, fixed,
 security, upstream, potato, woody, sarge, sid and experimental.

 For their meanings, consult the Control->Help->Tags menu.

"
                      ""))
           (bug-number (read-string (concat verbose "Bug number: ")))
           (add (completing-read "+, -, = (default +): "
                                 '(("+") ("-") ("=")) nil t nil nil "+"))
           (tag (completing-read "Tag: " debian-bug-alltags-alist nil t)))
      (insert (format "tags %s %s %s\n" bug-number add tag))))
   ((string-equal "close" action)
    (if (yes-or-no-p
         "Deprecated in favor of #BUG-close@bugs.debian.org. Continue? ")
        (let* ((verbose (if debian-bts-control-verbose-prompts-flag
                            "close bugnumber

 Close bug report #BUGNUMBER.

 A notification is sent to the user who reported the bug, but (in contrast
 to mailing bugnumber-done@bugs) the text of the mail which caused the bug
 to be closed is not included in that notification. The maintainer who
 closes a report needs to ensure, probably by sending a separate message,
 that the user who reported the bug knows why it is being closed. The use of
 this command is therefore deprecated.

"
                          ""))
               (bug-number (read-string (concat verbose "Bug number: "))))
          (insert (format "close %s\n" bug-number)))))
   ))



(defvar debian-bts-help-control-text
"Help text from http://www.debian.org/Bugs/server-control, Apr 22nd 2003.
Copyright 1999 Darren O. Benham, 1994-1997 Ian Jackson,
 1997 nCipher Corporation Ltd.

reassign bugnumber package

    Records that bug #bugnumber is a bug in package. This can be used to
    set the package if the user forgot the pseudo-header, or to change an
    earlier assignment. No notifications are sent to anyone (other than the
    usual information in the processing transcript).

reopen bugnumber [    originator-address | = | ! ]

    Reopens #bugnumber if it is closed.

    By default, or if you specify =, the original submitter is still as the
    originator of the report, so that they will get the ack when it is
    closed again.

    If you supply an originator-address the originator will be set to the
    address you supply. If you wish to become the new originator of the
    reopened report you can use the ! shorthand or specify your own email
    address.

    It is usually a good idea to tell the person who is about to be
    recorded as the originator that you're reopening the report, so that
    they will know to expect the ack which they'll get when it is closed
    again.

    If the bug is not closed then reopen won't do anything, not even change
    the originator. To change the originator of an open bug report, use the
    submitter command; note that this will inform the original submitter of
    the change.

submitter bugnumber originator-address | !

    Changes the originator of #bugnumber to originator-address.

    If you wish to become the new originator of the report you can use the
    ! shorthand or specify your own email address.

    While the reopen command changes the originator of other bugs merged
    with the one being reopened, submitter does not affect merged bugs.

forwarded bugnumber address

    Notes that bugnumber has been forwarded to the upstream maintainer at
    address. This does not actually forward the report. This can be used to
    change an existing incorrect forwarded-to address, or to record a new
    one for a bug that wasn't previously noted as having been forwarded.

notforwarded bugnumber

    Forgets any idea that bugnumber has been forwarded to any upstream
    maintainer. If the bug was not recorded as having been forwarded then
    this will do nothing.

retitle bugnumber new-title

    Changes the title of a bug report to that specified (the default is the
    Subject mail header from the original report.

    Unlike most of the other bug-manipulation commands when used on one of
    a set of merged reports this will change the title of only the
    individual bug requested, and not all those with which it is merged.

severity bugnumber severity

    Set the severity level for bug report #bugnumber to severity. No
    notification is sent to the user who reported the bug.

    Severities are critical, grave, serious, important, normal, minor, and
    wishlist.

    For their meanings please consult the general developers' documentation
    for the bug system.

clone bugnumber [ new IDs ]

    The clone control command allows you to duplicate a bug report. It is
    useful in the case where a single report actually indicates that
    multiple distinct bugs have occured. \"New IDs\" are negative numbers,
    separated by spaces, which may be used in subsequent control commands
    to refer to the newly duplicated bugs. A new report is generated for
    each new ID.

    Example usage:

        clone 12345 -1 -2
        reassign -1 foo
        retitle -1 foo: foo sucks
        reassign -2 bar
        retitle -2 bar: bar sucks when used with foo
        severity -2 wishlist
        clone 123456 -2
        reassign -2 foo
        retitle -2 foo: foo sucks
        merge -1 -2
  

merge bugnumber bugnumber ...

    Merges two or more bug reports. When reports are merged, opening,
    closing, marking or unmarking as forwarded and reassigning any of the
    bugs to a new package will have an identical effect on all of the
    merged reports.

    Before bugs can be merged they must be in exactly the same state:
    either all open or all closed, with the same forwarded-to upstream
    author address or all not marked as forwarded, all assigned to the same
    package or package(s) (an exact string comparison is done on the
    package to which the bug is assigned), and all of the same severity. If
    they don't start out in the same state you should use reassign, reopen
    and so forth to make sure that they are before using merge.

    If any of the bugs listed in a merge command is already merged with
    another bug then all the reports merged with any of the ones listed
    will all be merged together. Merger is like equality: it is reflexive,
    transitive and symmetric.

    Merging reports causes a note to appear on each report's logs; on the
    WWW pages this is includes links to the other bugs.

    Merged reports are all expired simultaneously, and only when all of the
    reports each separately meet the criteria for expiry.

unmerge bugnumber

    Disconnects a bug report from any other reports with which it may have
    been merged. If the report listed is merged with several others then
    they are all left merged with each other; only their associations with
    the bug explicitly named are removed.

    If many bug reports are merged and you wish to split them into two
    separate groups of merged reports you must unmerge each report in one
    of the new groups separately and then merge them into the required new
    group.

    You can only unmerge one report with each unmerge command; if you want
    to disconnect more than one bug simply include several unmerge commands
    in your message.

tags bugnumber [ + | - | = ] tag

    Sets a particular tag for the bug report #bugnumber to tag. No
    notification is sent to the user who reported the bug. + means adding,
    - means subtracting, and = means ignoring the current tags and setting
    them afresh. The default action is adding.

    Available tags currently include patch, wontfix, moreinfo,
    unreproducible, help, pending, fixed, security, upstream, potato,
    woody, sarge, sid and experimental.

    For their meanings please consult the general developers' documentation
    for the bug system.

close bugnumber

    Close bug report #bugnumber.

    A notification is sent to the user who reported the bug, but (in
    contrast to mailing bugnumber-done@bugs) the text of the mail which
    caused the bug to be closed is not included in that notification. The
    maintainer who closes a report needs to ensure, probably by sending a
    separate message, that the user who reported the bug knows why it is
    being closed. The use of this command is therefore deprecated.

quit
stop
thank...
--...

    Tells the control server to stop processing the message; the remainder
    of the message can include explanations, signatures or anything else,
    none of it will be detected by the control server.

#...

    One-line comment. The # must be at the start of the line.")

(provide 'debian-bts-control)

;;; debian-bts-control.el ends here
