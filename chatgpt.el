(require 'json)
(require 'auth-source)
(require 'url)

(defvar chatgpt-api-key "")

(defun chatgpt-prompt-for-prompt ()
  "Prompt the user for a prompt and return it as a string."
  (read-string "Prompt: "))

(defun chatgpt-get-api-key ()
  "Get the ChatGPT API key from the .authinfo file, if available.
   If chatgpt-api-key is set, return its value instead."
  (if chatgpt-api-key
      chatgpt-api-key
    (let ((match (car (auth-source-search :host "api.openai.com"
                                          :user "default"
                                          :require '(:secret)))))
      (if match
          (message "API %S" (funcall (plist-get match :secret)))
        (error "Unable to find ChatGPT API key in .authinfo")))))

(defun chatgpt-get-response (prompt)
  "Get a response from the ChatGPT API for the given PROMPT."
  (let* ((api-key (chatgpt-get-api-key))
         ;; replace davinci-codex in the url variable with the name of
         ;; the model you want to use

         ;;     davinci: This is the most powerful GPT-3 model
         ;;     and can generate very high-quality responses for
         ;;     a wide range of tasks.

         ;;     curie: This model is slightly less powerful than
         ;;     davinci, but still generates high-quality responses
         ;;     and is faster and more cost-effective.
         
         ;;     babbage: This model is designed for more structured text,
         ;;     such as filling out forms or generating code.

         ;;     ada: This model is designed specifically for natural language
         ;;     processing tasks and can generate responses that are more fluent
         ;;     and grammatically correct.
         (url "https://api.openai.com/v1/engines/davinci-codex/completions")
         ;; The max_tokens and temperature parameters are set correctly.
         ;; These parameters control how much text the ChatGPT API generates
         ;; and how "creative" the responses are. You can try adjusting these
         ;; parameters to see if it affects the output.
         (data `(("prompt" . ,prompt)
                 ("max_tokens" . "50")
                 ("n" . "1")
                 ("stop" . (string ?\n))
                 ("temperature" . "0.7")))
         (json-data (json-encode data))
         (url-request-method "POST")
         (url-request-extra-headers `(("Content-Type" . "application/json")
                                      ("Authorization" . ,(concat "Bearer " api-key))))
         (url-request-data json-data)
         (buffer (url-retrieve-synchronously url)))
    (with-current-buffer buffer
      (goto-char (point-min))
      (let ((end-of-headers (re-search-forward "^$" nil t)))
        (when end-of-headers
          (let ((json-object-type 'alist)
                (json-array-type 'list)
                (json-key-type 'string)
                (response-json (json-read-from-string (buffer-substring end-of-headers (point-max)))))
            ;; Debug output: print the entire JSON response to the minibuffer
            (message "CHATGPT JSON response: %S" response-json)
            ;; Extract the text from the first choice in the 'choices' array
            (cdr (assoc 'text (car (cdr (assoc 'choices response-json)))))))))))

(defun chatgpt ()
  "Generate a response to a prompt using the ChatGPT API."
  (interactive)
  (let ((prompt (chatgpt-prompt-for-prompt)))
    (switch-to-buffer (current-buffer))
    (insert (concat prompt "\n"))
    (insert (concat (chatgpt-get-response prompt) "\n\n"))))
