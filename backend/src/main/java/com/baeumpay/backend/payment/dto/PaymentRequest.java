package com.baeumpay.backend.payment.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record PaymentRequest(

        @NotNull
        Long merchantId,

        @NotNull
        @Positive
        Long amount

) {
}