package com.baeumpay.backend.inquiry.controller;

import com.baeumpay.backend.inquiry.dto.InquiryAnswerRequest;
import com.baeumpay.backend.inquiry.dto.InquiryCreateRequest;
import com.baeumpay.backend.inquiry.dto.InquiryResponse;
import com.baeumpay.backend.inquiry.service.InquiryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/inquiries")
public class InquiryController {

    private final InquiryService inquiryService;

    @PostMapping("/users/{userId}")
    public InquiryResponse createInquiry(
            @PathVariable Long userId,
            @Valid @RequestBody InquiryCreateRequest request
    ) {

        return inquiryService.createInquiry(
                userId,
                request
        );
    }

    @GetMapping("/users/{userId}")
    public List<InquiryResponse> getUserInquiries(
            @PathVariable Long userId
    ) {

        return inquiryService
                .getUserInquiries(userId);
    }

    @GetMapping("/{inquiryId}")
    public InquiryResponse getInquiry(
            @PathVariable Long inquiryId
    ) {

        return inquiryService
                .getInquiry(inquiryId);
    }

    @PostMapping("/{inquiryId}/answer")
    public InquiryResponse answerInquiry(
            @PathVariable Long inquiryId,
            @Valid @RequestBody InquiryAnswerRequest request
    ) {

        return inquiryService.answerInquiry(
                inquiryId,
                request
        );
    }
}