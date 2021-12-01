staload "SATS/stm32.sats"
staload "SATS/main.sats"
#define LED 13
#define BLINK_DELAY_MS 500.0


implement
main0 () =
{

 val () = loopProgr()
} (* end of [main0] *)
