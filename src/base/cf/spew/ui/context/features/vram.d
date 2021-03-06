/**
 * Render to Video Ram (VRAM) Buffer specialization support.
 *
 * Copyright: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors: $(LINK2 http://cattermole.co.nz, Richard Andrew Cattermole)
 */
module cf.spew.ui.context.features.vram;
import cf.spew.ui.rendering;
import cf.spew.ui.window.defs;
import cf.spew.ui.context.defs;
import devisualization.image : ImageStorage;
import devisualization.util.core.memory.managed;
import std.experimental.color : RGB8, RGBA8;

interface Have_VRamCtx {
    void assignVRamContext(bool withAlpha=false);
}

/**
 * Tells the render point creator to set the context to be VRAM.
 * If the platform does not support it, it will gracefully return.
 *
 * Params:
 *      self        =   The render point.
 *      withAlpha   =   Should the backing buffer have an alpha channel.
 */
void assignVRamContext(T)(managed!T self, bool withAlpha=false) if (is(T : IRenderPointCreator) || is(T : IWindowCreator)) {
    if (self is null)
        return;
	auto ss = cast(managed!Have_VRamCtx)self;
	if (ss !is null)
        ss.assignVRamContext(withAlpha);
}

interface Have_VRam {
    Feature_VRam __getFeatureVRam();
}

interface Feature_VRam {
    @property {
        ImageStorage!RGB8 vramBuffer();
        ImageStorage!RGBA8 vramAlphaBuffer();
    }
}

@property {
    /**
     * Gets the VRAM buffer as an RGB8 image.
     *  
     * If the context doesn't support VRAM it will return null.
     *
     * If the backing buffer supports alpha, it will be set to the max of 255.
     *
     * Returns:
     *      The VRAM buffer or null on failure.
     */
    ImageStorage!RGB8 vramBuffer(IContext self) {
        if (self is null)
            return null;
        if (Have_VRam ss = cast(Have_VRam)self) {
            return ss.__getFeatureVRam().vramBuffer;
        }
        
        return null;
    }

    /**
     * Gets the VRAM buffer as an RGBA8 image.
     * 
     * If the context doesn't support VRAM it will return null.
     *
     * If the backing buffer does not support alpha, it will be ignored.
     * 
     * Returns:
     *      The VRAM buffer or null on failure.
     */
	ImageStorage!RGBA8 vramAlphaBuffer(IContext self) {
        if (self is null)
            return null;
        if (Have_VRam ss = cast(Have_VRam)self) {
            return ss.__getFeatureVRam().vramAlphaBuffer;
        }
        
        return null;
    }

	/**
	 * Does the given context support VRAM buffer for drawing?
	 * 
	 * Params:
	 * 		self	=	The platform instance
	 * 
	 * Returns:
	 * 		If the context supports drawing via a VRAM buffer
	 */
	bool capableOfVRAM(IContext self) {
		if (self is null)
			return false;
		else if (Have_VRam ss = cast(Have_VRam)self)
			return ss.__getFeatureVRam() !is null;
		else
			return false;
	}
}
