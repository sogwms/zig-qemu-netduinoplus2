programFile=`ls zig-out/bin/*.bin | head -n 1`

qemu-system-arm -M netduinoplus2 -nographic -serial mon:stdio -kernel ${programFile}
