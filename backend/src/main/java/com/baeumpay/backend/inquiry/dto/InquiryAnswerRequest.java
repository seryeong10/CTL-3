package com.baeumpay.backend.inquiry.dto;

import jakarta.validation.constraints.NotBlank;

public record InquiryAnswerRequest(

        @NotBlank
        String answer

) {
}