package com.baeumpay.backend.inquiry.service;

import com.baeumpay.backend.inquiry.dto.InquiryAnswerRequest;
import com.baeumpay.backend.inquiry.dto.InquiryCreateRequest;
import com.baeumpay.backend.inquiry.dto.InquiryResponse;
import com.baeumpay.backend.inquiry.entity.Inquiry;
import com.baeumpay.backend.inquiry.repository.InquiryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InquiryService {

    private final InquiryRepository inquiryRepository;

    @Transactional
    public InquiryResponse createInquiry(
            Long userId,
            InquiryCreateRequest request
    ) {

        Inquiry inquiry = new Inquiry(
                userId,
                request.type(),
                request.title(),
                request.content()
        );

        Inquiry savedInquiry =
                inquiryRepository.save(inquiry);

        return InquiryResponse.from(savedInquiry);
    }

    public List<InquiryResponse> getUserInquiries(
            Long userId
    ) {

        return inquiryRepository
                .findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(InquiryResponse::from)
                .toList();
    }

    public InquiryResponse getInquiry(
            Long inquiryId
    ) {

        Inquiry inquiry =
                inquiryRepository.findById(inquiryId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "문의를 찾을 수 없습니다."
                                )
                        );

        return InquiryResponse.from(inquiry);
    }

    @Transactional
    public InquiryResponse answerInquiry(
            Long inquiryId,
            InquiryAnswerRequest request
    ) {

        Inquiry inquiry =
                inquiryRepository.findById(inquiryId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "문의를 찾을 수 없습니다."
                                )
                        );

        inquiry.answer(request.answer());

        return InquiryResponse.from(inquiry);
    }
}