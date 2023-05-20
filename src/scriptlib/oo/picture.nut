

/*!
	@short	Picture binding.
*/
class		Picture
{
	handle			=	0;

	function		Fill(r, g, b, a)
	{	PictureFill(handle, r, g, b, a);	}

	function		GetRect()
	{	return PictureGetRect(handle);	}

	function		TextRender(rect, text, font, parm)
	{	PictureTextRender(handle, rect, text, font, parm);	}
	function        ApplyConvolution(kernel_width, kernel_height, kernel)
	{	return PictureApplyConvolution(handle, kernel_width, kernel_height, kernel);	}

	function        LoadContent(path)
	{	return PictureLoadContent(handle, path);	}

	function		GetHandle()
	{	return handle;	}
	constructor(h)
	{	handle = h;	}
}
