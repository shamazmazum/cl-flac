;; Copyright (c) 2012-2014, Vasily Postnicov
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

;; This is actually utility functions just like in flac/flac-reader.lisp
(in-package :easy-audio.wv)

;; FIXME: is there a better way to keep these magic numbers out of code?
;; Can we calculate them in place?
(declaim (type (sa-ub 8) +exp2-table+))
(defparameter +exp2-table+
  (make-array (list 256)
              :element-type '(ub 8)
              :initial-contents
              '#.(with-open-file (in (merge-pathnames "exp2table.lisp-expr"
                                                      *compile-file-truename*))
                   (read in))))

(declaim (ftype (function ((ub 16)) (sb 32)) exp2s))
(defun exp2s (val)
  (declare (optimize (speed 3))
           (type (ub 16) val))
  (if (< val #x8000)
      (let ((m (logior (aref +exp2-table+
                             (logand val #xff))
                       #x100))
            (exp (ash val -8)))
        (ash m (- exp 9)))
      (- (exp2s (1+ (logxor #xffff val))))))
;; Next two functions are just a KLUDGE and almost copy functionality of the bitreader.
;; Try to develop more flexible bitreader instead
(defun residual-read-bit (reader)
  (with-accessors ((ibyte bitreader::reader-ibyte)
                   (ibit  bitreader::reader-ibit)
                   (end   bitreader::reader-end)) reader
  (if (< ibyte end)
      (prog1
          (ldb (byte 1 ibit)
               (aref (bitreader::reader-buffer reader) ibyte))
        (if (= ibit 7)
            (setf ibit 0
                  ibyte (1+ ibyte))
            (incf ibit)))
      (error 'bitreader-eof :bitreader reader))))

(defun residual-read-bits (bits reader)
  (let ((result 0)
        (already-read 0))
    (with-accessors ((ibit  bitreader::reader-ibit)
                     (ibyte bitreader::reader-ibyte)
                     (end   bitreader::reader-end)) reader
      (dotimes (i (ceiling (+ bits ibit) 8))
        (if (= ibyte end) (error 'bitreader-eof :bitreader reader))
        (let ((bits-to-add (min bits (- 8 ibit))))
          (setq result (logior result (ash (ldb
                                            (byte bits-to-add ibit)
                                            (aref (bitreader::reader-buffer reader) ibyte))
                                           already-read))
                bits (- bits bits-to-add)
                already-read (+ already-read bits-to-add))

          (incf ibit bits-to-add)
          (if (= ibit 8)
              (setf ibit 0
                    ibyte (1+ ibyte))))))
    result))

(defun read-zero-run-length (reader)
  (let ((ones-num
         (loop for one = (residual-read-bit reader)
               while (= one 1) count one)))
    (if (/= ones-num 0)
        (let ((shift (1- ones-num)))
          (logior (ash 1 shift)
                  (residual-read-bits shift reader))) 0)))

;; From flac reader
#|(declaim (inline unsigned-to-signed)
	 (ftype (function ((ub 32)
			   (integer 0 32))
			  (sb 32))
		unsigned-to-signed))
(defun unsigned-to-signed (byte len)
  (declare (type (integer 0 32) len)
	   (type (ub 32) byte))
  (let ((sign-mask (ash 1 (1- len))))
    (if (< byte sign-mask)
        byte
        (- byte (ash sign-mask 1)))))|#
