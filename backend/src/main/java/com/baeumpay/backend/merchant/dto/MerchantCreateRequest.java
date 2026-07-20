package com.baeumpay.backend.merchant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record MerchantCreateRequest(

        @NotBlank
        String name,

        @NotBlank
        String address,

        @NotNull
        Double latitude,

        @NotNull
        Double longitude,

        @NotBlank
        String phoneNumber,

        @NotBlank
        String businessHours

) {
}