package com.baeumpay.backend.payment.dto;

import com.baeumpay.backend.payment.entity.Payment;
import com.baeumpay.backend.payment.entity.PaymentStatus;

import java.time.LocalDateTime;

public record PaymentResponse(
        Long paymentId,
        Long userId,
        Long merchantId,
        Long usedPoint,
        Long remainingBalance,
        PaymentStatus status,
        LocalDateTime createdAt,
        String message
) {

    public static PaymentResponse of(
            Payment payment,
            Long remainingBalance
    ) {

        return new PaymentResponse(
                payment.getPaymentId(),
                payment.getUserId(),
                payment.getMerchantId(),
                payment.getAmount(),
                remainingBalance,
                payment.getStatus(),
                payment.getCreatedAt(),
                "포인트 결제가 완료되었습니다."
        );
    }
}