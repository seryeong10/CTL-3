package com.baeumpay.backend.global.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(
            IllegalArgumentException exception
    ) {

        ErrorResponse response = ErrorResponse.of(
                HttpStatus.BAD_REQUEST.value(),
                exception.getMessage()
        );

        return ResponseEntity
                .badRequest()
                .body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException exception
    ) {

        String message =
                exception.getBindingResult()
                        .getFieldErrors()
                        .stream()
                        .findFirst()
                        .map(error ->
                                error.getField()
                                        + ": "
                                        + error.getDefaultMessage()
                        )
                        .orElse(
                                "요청 값이 올바르지 않습니다."
                        );

        ErrorResponse response = ErrorResponse.of(
                HttpStatus.BAD_REQUEST.value(),
                message
        );

        return ResponseEntity
                .badRequest()
                .body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(
            Exception exception
    ) {

        ErrorResponse response = ErrorResponse.of(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "서버 내부 오류가 발생했습니다."
        );

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(response);
    }
}