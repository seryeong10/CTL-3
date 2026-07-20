package com.baeumpay.backend.payment.repository;

import com.baeumpay.backend.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository
        extends JpaRepository<Payment, Long> {
}