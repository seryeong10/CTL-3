package com.baeumpay.backend.inquiry.dto;

import com.baeumpay.backend.inquiry.entity.InquiryType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record InquiryCreateRequest(

        @NotNull
        InquiryType type,

        @NotBlank
        String title,

        @NotBlank
        String content

) {
}