(in-package :cl-flac)

(defun metadata-header-reader (stream header)
  (with-slots (last-block-p type length) header
	      (setf last-block-p (tbs:read-bit stream)
		    type (tbs:read-bits 7 stream)
		    length (tbs:read-bits 24 stream)))
  header)

(defun metadata-reader (stream)
  (let ((data (make-instance 'metadata-header)))
    (metadata-header-reader stream data)
    
    (handler-case
     (let ((mtype (get-metadata-type (slot-value data 'type))))
       (change-class data mtype))
     (error () ())) ; Надо обрабатывать более специфичную ошибку из get-reader

    (metadata-body-reader stream data)
    data))

(defmethod metadata-body-reader (stream (data padding))
  (declare (ignore stream))
  ;; Read length bytes
  (call-next-method)
  ;; Sanity check
  (if (find-if-not #'zerop (slot-value data 'rawdata))
      (error "Padding bytes is not zero")))

(defmethod metadata-body-reader (stream (data streaminfo))
  (with-slots (minblocksize maxblocksize) data
	      (setf minblocksize (tbs:read-bits 16 stream)
		    maxblocksize (tbs:read-bits 16 stream)))
	      
  (with-slots (minframesize maxframesize) data
		(setf minframesize (tbs:read-bits 24 stream)
		      maxframesize (tbs:read-bits 24 stream)))

  (with-slots (samplerate channels bitspersample totalsamples) data
	      (setf samplerate (tbs:read-bits 20 stream)
		    channels (1+ (tbs:read-bits 3 stream))
		    bitspersample (1+ (tbs:read-bits 5 stream))
		    totalsamples (tbs:read-bits 36 stream)))
  
  (let ((md5 (make-array 16 :element-type 'u8)))
    (tbs:read-octet-vector md5 stream)
    (setf (streaminfo-md5 data) md5))
  data)

(defmethod metadata-body-reader (stream (data metadata-header))
  (let ((chunk (make-array (slot-value data 'length) :element-type 'u8)))
    (tbs:read-octet-vector chunk stream)
    (setf (slot-value data 'rawdata) chunk))) ; For debugging
