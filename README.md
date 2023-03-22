# emacs-chatgpt
emacs script to use chatgpt.
you can use the .authinfo file to add the api key
example:
```sh
machine api.openai.com login default password API-KEY
```

or in emacs you can use:

```lisp
  (setq chatgpt-api-key "API-KEY")
```

if you are using spacemacs:

```lisp
(defun dotspacemacs/user-config ()
  (setq chatgpt-api-key "API-KEY"))
```
