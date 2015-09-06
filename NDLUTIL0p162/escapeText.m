function txt = escapeText(txt)

% ESCAPETEXT Add back slashes to escape existing backslashes in a text.
%
%	Description:
%	txt = escapeText(txt)
%% 	escapeText.m SVN version 797
% 	last update 2010-05-19T06:50:25.000000Z
  
txt = strrep(txt, '\', '\\');
txt = strrep(txt, '%', '%%');