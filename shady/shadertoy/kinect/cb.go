package kinect

// #include "libfreenect.h"
import "C"
import "fmt"

//export rgbCallbackGo
func rgbCallbackGo(dev *C.freenect_device, rgbPtr *uint8, timestamp C.uint32_t) {
	instanceHandle := uintptr(C.freenect_get_user(dev))
	h, ok := instances.Load(instanceHandle)
	if !ok {
		panic(fmt.Errorf("kinect: instance not found, handle=%v", instanceHandle))
	}
	kin := h.(*kinect)
	kin.rgbCallback(rgbPtr)
}

//export depthCallbackGo
func depthCallbackGo(dev *C.freenect_device, depthPtr *uint8, timestamp C.uint32_t) {
	instanceHandle := uintptr(C.freenect_get_user(dev))
	h, ok := instances.Load(instanceHandle)
	if !ok {
		panic(fmt.Errorf("kinect: instance not found, handle=%v", instanceHandle))
	}
	kin := h.(*kinect)
	kin.depthCallback(depthPtr)
}
