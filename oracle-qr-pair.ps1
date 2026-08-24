# ============================================================
# OpenWA - QR pairing helper (run on YOUR Windows PC)
# Downloads the QR code from the Oracle VM and opens it,
# then waits until the session is connected.
#
# Usage:  pwsh oracle-qr-pair.ps1 -VM_IP 129.146.xx.xx
# ============================================================
param(
    [Parameter(Mandatory = $true)][string]$VM_IP,
    [string]$SessionName = "oracle-main"
)

$base = "http://$VM_IP`:2785"

# 1) API key — it lives on the VM:  sudo cat ~/openwa-data/.api-key
$key = Read-Host "API key paste karo (VM par: sudo cat ~/openwa-data/.api-key)"
$h = @{ "X-API-Key" = $key }

# 2) Find or create the session
$sessions = Invoke-RestMethod -Uri "$base/api/sessions" -Headers $h -TimeoutSec 15
$session = $sessions | Where-Object { $_.name -eq $SessionName }
if ($session) {
    $sessionId = $session.id
    Write-Host "Session mil gayi: $SessionName ($sessionId)"
} else {
    Write-Host "Nayi session bana raha hoon: $SessionName"
    $body = @{ name = $SessionName } | ConvertTo-Json
    $created = Invoke-RestMethod -Method Post -Uri "$base/api/sessions" -Headers $h -Body $body -ContentType "application/json" -TimeoutSec 15
    $sessionId = $created.id
}

# 3) Start the session and grab the QR
try { Invoke-RestMethod -Method Post -Uri "$base/api/sessions/$sessionId/start" -Headers $h -TimeoutSec 10 | Out-Null } catch { Write-Host "(start already running?)" }
Start-Sleep -Seconds 10

$qr = Invoke-RestMethod -Uri "$base/api/sessions/$sessionId/qr" -Headers $h -TimeoutSec 20
$b64 = ($qr.qrCode -replace '^data:image/png;base64,', '')
$qrPath = Join-Path $PSScriptRoot "qr-oracle.png"
[System.IO.File]::WriteAllBytes($qrPath, [System.Convert]::FromBase64String($b64))
Write-Host "QR code save hua: $qrPath — ab phone se scan karo!"
Start-Process $qrPath

# 4) Wait until connected
Write-Host "Session connect hone ka wait kar raha hoon..."
do {
    Start-Sleep -Seconds 5
    try { $s = Invoke-RestMethod -Uri "$base/api/sessions/$sessionId" -Headers $h -TimeoutSec 10; Write-Host "  status: $($s.status)" }
    catch { Write-Host "  (polling...)" }
} while ($s.status -notin @('ready', 'connected', 'failed', 'disconnected'))

if ($s.status -eq 'ready' -or $s.status -eq 'connected') {
    Write-Host ""
    Write-Host "=============================================="
    Write-Host " CONNECTED! WhatsApp automation ab cloud par live hai! "
    Write-Host "=============================================="

    # 5) Create the same 3 automation rules as your local setup
    $rules = @(
        @{ name = "Away auto-reply"; replyText = "Hello! I'm currently away from phone. I'll reply to you as soon as possible. Thank you!"; conditions = $null; cooldownSeconds = 120; enabled = $true },
        @{ name = "Price enquiry"; replyText = "Thanks for asking about our pricing! Prices start from Rs. 499. Please share more details and I'll get back to you."; conditions = @{ conditions = @(@{ field = "body"; operator = "contains"; value = "price" }) }; cooldownSeconds = 300; enabled = $true },
        @{ name = "Help request"; replyText = "Need help? Please describe your issue and our team will reach out shortly."; conditions = @{ conditions = @(@{ field = "body"; operator = "contains"; value = "help" }) }; cooldownSeconds = 300; enabled = $true }
    )
    foreach ($r in $rules) {
        $body = $r | ConvertTo-Json -Depth 5
        try {
            $rule = Invoke-RestMethod -Method Post -Uri "$base/api/sessions/$sessionId/automation-rules" -Headers $h -Body $body -ContentType "application/json" -TimeoutSec 15
            Write-Host "  Rule ban gayi: $($rule.name)"
        } catch {
            Write-Host "  Rule fail: $($_.Exception.Message)"
        }
    }
    Write-Host ""
    Write-Host "Sab rules bhi bana diye! Test: kisi dusre number se message bhejo."
} else {
    Write-Host ""
    Write-Host "Status: $($s.status) — QR scan sahi hua? Dobara try karo ya VM logs dekho:"
    Write-Host "  sudo docker logs openwa --tail 50"
}
