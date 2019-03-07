local function tikz2image(src, filetype, outfile)
    --- Create a standalone LaTeX document which contains only the TikZ picture.
    --- Optionally convert to png via Imagemagick.
    local tmp = os.tmpname()
    local tmpdir = string.match(tmp, "^(.*[\\/])") or "."
    local f = io.open(tmp .. ".tex", 'w')
    f:write("\\documentclass{standalone}\n\\usepackage{tikz}\n\\usepackage{stix}\n\\begin{document}\n")
    f:write(src)
    f:write("\n\\end{document}\n")
    f:close()
    os.execute("pdflatex -output-directory " .. tmpdir  .. " " .. tmp)
    os.rename(tmp .. ".pdf", outfile .. ".pdf")
    if filetype ~= 'pdf' then
        os.execute("convert " .. outfile .. ".pdf " .. outfile .. "." .. filetype)
    end

end

extension_for = {
    html = 'png',
    html4 = 'png',
    html5 = 'png',
    latex = 'pdf',
    beamer = 'pdf' }

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function RawBlock(el)
  -- Don't alter element if it's not a tikzpicture environment
  if not el.text:match'^\\begin{tikzpicture}' then
    return nil
    -- Alternatively, parse the contained LaTeX now:
    -- return pandoc.read(el.text, 'latex').blocks
  end
    local filetype = extension_for[FORMAT] or "png"
    local fname = pandoc.sha1(el.text) .. "." .. filetype
    if not file_exists(fname) then
        tikz2image(el.text, filetype, pandoc.sha1(el.text))
    end
    return pandoc.Para({pandoc.Image({}, fname)})
end
