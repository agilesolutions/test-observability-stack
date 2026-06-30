package com.agilesolutions.service_b.controller;

import com.agilesolutions.common.domain.ServiceInfo;
import com.agilesolutions.service_b.service.InfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/service-b")
@RequiredArgsConstructor
public class InfoController {

    private final InfoService infoService;

    @GetMapping("/info")
    public ResponseEntity<ServiceInfo> getInfo() {
        return infoService.getInfo("default")
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
