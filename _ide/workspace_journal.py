# 2026-10-12T21:01:19.311740800
import vitis

client = vitis.create_client()
client.set_workspace(path="Lesson_15")

comp = client.create_hls_component(name = "moving_max",part = "xc7z045ffg900-2",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

cfg = client.get_config_file(path="I:\Xilinx_Projects\Lesson_15\moving_max\hls_config.cfg")

cfg.set_values(key="tb.file", values=["C:/Users/Bohdan Bloshchynskyi/Downloads/tb_moving_max.cpp"])

cfg = client.get_config_file(path="/i:/Xilinx_Projects/Lesson_15/moving_max/hls_config.cfg")

cfg = client.get_config_file(path="/i:/Xilinx_Projects/Lesson_15/moving_max/hls_config.cfg")

cfg = client.get_config_file(path="/i:/Xilinx_Projects/Lesson_15/moving_max/hls_config.cfg")

cfg = client.get_config_file(path="/i:/Xilinx_Projects/Lesson_15/moving_max/hls_config.cfg")

cfg = client.get_config_file(path="/i:/Xilinx_Projects/Lesson_15/moving_max/hls_config.cfg")

cfg.set_values(key="syn.file_csimflags", values=[])

cfg.set_values(key="syn.file", values=["I:/Xilinx_Projects/Lesson_15/moving_max/moving_max.cpp", "../../git clones/FPGA/lesson_15/HW/moving_max.h"])

cfg.set_values(key="syn.file_cflags", values=[])

cfg.set_value(section="hls", key="syn.csimflags", value="")

cfg.set_value(section="hls", key="syn.cflags", value="")

cfg.set_values(key="syn.file_cflags", values=[])

cfg.set_value(section="hls", key="syn.csimflags", value="")

cfg.set_value(section="hls", key="syn.cflags", value="")

cfg.set_values(key="syn.file_csimflags", values=[])

cfg.set_values(key="syn.file", values=["I:/Xilinx_Projects/Lesson_15/moving_max/moving_max.cpp", "I:/Xilinx_Projects/Lesson_15/moving_max/moving_max.h"])

comp = client.get_component(name="moving_max")
comp.run(operation="C_SIMULATION")

cfg.set_values(key="tb.file_cflags", values=[])

cfg.set_value(section="hls", key="tb.cflags", value="")

cfg.set_value(section="hls", key="syn.csimflags", value="")

cfg.set_values(key="tb.file", values=["I:/Xilinx_Projects/Lesson_15/moving_max/tb_moving_max.cpp"])

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

comp.run(operation="PACKAGE")

