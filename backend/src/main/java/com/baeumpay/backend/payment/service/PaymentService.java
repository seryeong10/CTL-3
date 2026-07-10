package com.baeumpay.backend.payment.service;

import com.baeumpay.backend.merchant.entity.Merchant;
import com.baeumpay.backend.merchant.repository.MerchantRepository;
import com.baeumpay.backend.payment.dto.PaymentResponse;
import com.baeumpay.backend.payment.entity.Payment;
import com.baeumpay.backend.payment.repository.PaymentRepository;
import com.baeumpay.backend.point.entity.PointSourceType;
import com.baeumpay.backend.point.entity.PointTransaction;
import com.baeumpay.backend.point.entity.PointTransactionType;
import com.baeumpay.backend.point.entity.PointWallet;
import com.baeumpay.backend.point.repository.PointTransactionRepository;
import com.baeumpay.backend.point.repository.PointWalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PaymentService {

    private final PaymentRepository paymentRepository;

    private final PointWalletRepository pointWalletRepository;

    private final PointTransactionRepository pointTransactionRepository;

    private final MerchantRepository merchantRepository;

    @Transactional
    public PaymentResponse pay(
            Long userId,
            Long merchantId,
            Long amount
    ) {

        Merchant merchant =
                merchantRepository.findById(merchantId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "가맹점을 찾을 수 없습니다."
                                )
                        );

        if (!Boolean.TRUE.equals(merchant.getActive())) {
            throw new IllegalArgumentException(
                    "현재 이용할 수 없는 가맹점입니다."
            );
        }

        PointWallet wallet =
                pointWalletRepository.findByUserId(userId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "포인트 지갑을 찾을 수 없습니다."
                                )
                        );

        wallet.use(amount);

        Payment payment = new Payment(
                userId,
                merchantId,
                amount
        );

        Payment savedPayment =
                paymentRepository.save(payment);

        PointTransaction transaction =
                new PointTransaction(
                        userId,
                        PointTransactionType.USE,
                        amount,
                        PointSourceType.PAYMENT,
                        savedPayment.getPaymentId(),
                        merchant.getName() + " 포인트 결제"
                );

        pointTransactionRepository.save(transaction);

        return PaymentResponse.of(
                savedPayment,
                wallet.getBalance()
        );
    }
}