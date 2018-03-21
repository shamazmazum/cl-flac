;; Copyright (c) 2012-2013, Vasily Postnicov
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met: 

;; 1. Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimer. 
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution. 

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
;; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(defpackage easy-audio.wav
  (:use #:cl #:bitreader #:utils #:easy-audio-early)
  (:nicknames #:wav)
  (:export #:+wav-id+   ; Useful constants which can be used in examples
           #:+wav-format+
           #:+format-subchunk+
           #:+data-subchunk+

           #:+wave-format-pcm+
           #:+wave-format-float+
           #:+wave-format-alaw+
           #:+wave-format-mulaw+
           #:+wave-format-extensible+

           #:format-audio-format ; Format subchunk and accessors
           #:format-channels-num
           #:format-samplerate
           #:format-bps
           #:format-valid-bps
           #:format-channel-mask
           #:format-subchunk

           #:data-subchunk  ; Data subchunk and accessors
           #:data-size

           #:fact-subchunk ; Fact subchunk and accessors
           #:fact-samples-num

           #:wav-error  ; Conditions
           #:wav-error-subchunk

           #:skip-subchunk ; Restarts

           #:open-wav
           #:read-wav-header
           #:read-wav-data
           #:decode-wav-data
           #:samples-num)) ; Helper function
