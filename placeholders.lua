--[[ Reference text for placeholders (multiple segments for translation files). ]]

return function(_)
    local header = _([[Title & stats lines use the same codes as the KOReader sleep screen message editor:

]])
    local body_codes = _([[%T title
%A author
%S series
%t total pages
%c current page
%l pages left in chapter
%p book percentage read
%H time left in book
%C chapter title
%P chapter percentage read
%h time left in chapter
%F file path
%f file name
%b battery level
%B battery symbol
%r separator (reader footer separator)
%D current date (yyyy-mm-dd)
%d current date (mm-dd)
%m current time (hh:mm)
%M current time (hh:mm:ss)
]])
    local footer_intro = _([[


Quote footer (under the highlight) uses doubled percents so it does not clash with KOReader codes:

]])
    local footer_codes = _([[%%DT date of highlight (short)
%%HM time of highlight (hh:mm)
%%PG page / page label of highlight
%%C chapter of highlight
%%A author (document metadata)
%%T title (document metadata)

Use \n in templates for a line break.
]])
    return header .. body_codes .. footer_intro .. footer_codes
end
