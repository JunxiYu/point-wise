%--------------------------------------------------------------------%
%	    Alison Chaiken, sole author and maintainer     			     %
%        ------------------------------------------------------      %
%	    GUI-based Matlab and FEMLAB data analysis, instrument	     %
%	    control, statistical analysis, finite-element modelling,     %
%	    image acquisition and analysis          				     %
%       -------------------------------------------------------      %
%	    alchaiken@gmail.com			                    		     %
%	    http://www.exerciseforthereader.org/         			     %
%	    (001)650-279-5600					                         %
%--------------------------------------------------------------------%

% Using the user-specified magnification value, draw a scalebar on the
% image.   Does not redraw the image if the desire for a scalebar is
% withdrawn. (Is this the user-expected behavior?)   Accuracy of the scale
% bar depends on the correctness of handles.ScaleFactor, which relies on a
% per-instrument one-time calibration.

%	exxes=[100 (100 + (50/SCALEFACTOR))];
%whys=[300 300];

%scalebar is drawn on the figure with the image display
%currhandles = get(handles.Image)
try
    currentaxes = get(handles.Image,'CurrentAxes');
catch % do nothing if image is not open
    %errordlg('Add scale bar once image is open.')
    return
end
axes(currentaxes);
scalebaryoffset=handles.ImageHeight/10;
whys=[scalebaryoffset scalebaryoffset];
scalebarxoffset=handles.ImageWidth/20;
if (get(handles.Magnification,'value') < 1000)
    %exxes=[100 (100 + (100/handles.ScaleFactor))];
    exxes=[scalebarxoffset (scalebarxoffset + (100.0/handles.ScaleFactor))];
    scalebar=line(exxes,whys);
    text(exxes(2)+10,whys(1),'100 \mum','color','w','fontsize',18);
else
    %exxes=[100 (100 + (1/handles.ScaleFactor))];
    exxes=[scalebarxoffset (scalebarxoffset + (1.0/handles.ScaleFactor))];
    scalebar=line(exxes,whys);
    text(exxes(2)+10,whys(1),'1 \mum','color','w','fontsize',18);
end
set(scalebar,'color','w','linewidth',4)