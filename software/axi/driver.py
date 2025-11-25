import time
from pynq import Overlay

from .enums import MemOp, MemSize, MemOpStatus, MemOpResult

class SimpleAxiMasterDriver:
    def __init__(self, overlay_path: str) -> None:
        self._ol = Overlay(overlay_path)
        
        print("Parsing HWH:", self._ol.is_loaded())
        print("Available IPs:", list(self._ol.ip_dict.keys()))
        print("Hierarchy:", list(self._ol.hierarchy_dict.keys()))

        self.gpio_wdata = self._ol.gpio_wdata.channel1
        self.gpio_rdata = self._ol.gpio_rdata.channel1
        self.gpio_addr = self._ol.gpio_addr.channel1
        self.gpio_ctrl = self._ol.gpio_ctrl.channel1
        self.gpio_status = self._ol.gpio_ctrl.channel2

    @property
    def rdata(self) -> int:
        return self.gpio_rdata.read()
    
    @property
    def status(self) -> int:
        return self.gpio_status.read()
    
    @property
    def wdata(self) -> int:
        return self.gpio_wdata.read()
    
    @wdata.setter
    def wdata(self, data: int) -> None:
        return self.gpio_wdata.write(data)
    
    @property
    def addr(self) -> int:
        return self.gpio_addr.read()

    @addr.setter
    def addr(self, addr: int) -> None:
        return self.gpio_addr.write(addr)
    
    @property
    def ctrl(self) -> int:
        return self.gpio_ctrl.read()

    @ctrl.setter
    def ctrl(self, ctrl: int) -> None:
        return self.gpio_ctrl.write(ctrl)

    @staticmethod
    def __make_ctrl(clear: bool = False, cmd: MemOp | int = MemOp.IDLE, size: MemSize | int = MemSize.BYTE) -> int:
        # [5:5]=Clear, [4:3]=RW, [2:0]=Size, start transaction
        return (int(clear) << 5) | ((cmd & 0x3) << 3) | (size & 0x7)

    def _execute(self, cmd: MemOp | int, size: MemSize | int, addr: int, data: int = 0) -> MemOpResult:
        """Execute raw transfer"""
        self.addr = addr

        if cmd == MemOp.WRITE:
            self.wdata = data & 0xFFFF_FFFF

        self.ctrl = self.__make_ctrl(False, cmd, size)

        status = 0
        for _ in range(100):
            status = self.status
            done = (status >> 1) & 0x1
            if done:
                break
            time.sleep(0.001)

        # Return to idle
        self.ctrl = self.__make_ctrl()

        # Read result
        result_data = 0
        if cmd == MemOp.READ:
            result_data = self.rdata

        return MemOpResult(MemOpStatus.from_reg(status), result_data)
    
    def clear(self) -> None:
        self.ctrl = self.__make_ctrl(clear=True)
        time.sleep(0.01)
        self.ctrl = self.__make_ctrl()

    def read(self, size: MemSize, addr: int) -> MemOpResult:
        return self._execute(MemOp.READ, size, addr)
    
    def read_byte(self, addr: int) -> MemOpResult:
        return self._execute(MemOp.READ, MemSize.BYTE, addr)
    
    def read_half(self, addr: int) -> MemOpResult:
        return self._execute(MemOp.READ, MemSize.HALF, addr)
    
    def read_word(self, addr: int) -> MemOpResult:
        return self._execute(MemOp.READ, MemSize.WORD, addr)
    
    def read_dword(self, addr: int) -> MemOpResult:
        return self._execute(MemOp.READ, MemSize.DWORD, addr)

    def write(self, size: MemSize, addr: int, data: int) -> MemOpStatus:
        return self._execute(MemOp.WRITE, size, addr, data).status
    
    def write_byte(self, addr: int, data: int) -> MemOpStatus:
        return self._execute(MemOp.WRITE, MemSize.BYTE, addr, data).status
    
    def write_half(self, addr: int, data: int) -> MemOpStatus:
        return self._execute(MemOp.WRITE, MemSize.HALF, addr, data).status
    
    def write_word(self, addr: int, data: int) -> MemOpStatus:
        return self._execute(MemOp.WRITE, MemSize.WORD, addr, data).status
    
    def write_dword(self, addr: int, data: int) -> MemOpStatus:
        return self._execute(MemOp.WRITE, MemSize.DWORD, addr, data).status
