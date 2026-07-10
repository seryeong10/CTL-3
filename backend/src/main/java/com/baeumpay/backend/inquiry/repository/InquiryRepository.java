package com.baeumpay.backend.inquiry.repository;

import com.baeumpay.backend.inquiry.entity.Inquiry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InquiryRepository
        extends JpaRepository<Inquiry, Long> {

    List<Inquiry> findByUserIdOrderByCreatedAtDesc(
            Long userId
    );
}