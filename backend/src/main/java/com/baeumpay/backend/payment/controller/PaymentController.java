package com.baeumpay.backend.payment.controller;

import com.baeumpay.backend.payment.dto.PaymentRequest;
import com.baeumpay.backend.payment.dto.PaymentResponse;
import com.baeumpay.backend.payment.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/{userId}")
    public PaymentResponse pay(
            @PathVariable Long userId,
            @Valid @RequestBody PaymentRequest request
    ) {

        return paymentService.pay(
                userId,
                request.merchantId(),
                request.amount()
        );
    }
}