package com.baeumpay.backend.inquiry.dto;

import com.baeumpay.backend.inquiry.entity.Inquiry;
import com.baeumpay.backend.inquiry.entity.InquiryStatus;
import com.baeumpay.backend.inquiry.entity.InquiryType;

import java.time.LocalDateTime;

public record InquiryResponse(
        Long inquiryId,
        Long userId,
        InquiryType type,
        String title,
        String content,
        InquiryStatus status,
        String answer,
        LocalDateTime createdAt,
        LocalDateTime answeredAt
) {

    public static InquiryResponse from(
            Inquiry inquiry
    ) {

        return new InquiryResponse(
                inquiry.getInquiryId(),
                inquiry.getUserId(),
                inquiry.getType(),
                inquiry.getTitle(),
                inquiry.getContent(),
                inquiry.getStatus(),
                inquiry.getAnswer(),
                inquiry.getCreatedAt(),
                inquiry.getAnsweredAt()
        );
    }
}