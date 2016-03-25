-- raikia-screenshot.nse  -  Designed for Kali 2.0
-- By Chris King
--
-- This nmap script will take a screenshot of http[s]://ip:port, as well as http[s]://hostname:port AND https://sslcert_name:port
-- All screenshots will be stored in a subfolder named "screenshots"
--
-- To use this script, you must first run:
--      apt-get install wkimagetopdf



description = [[
Screenshots each host using their IP, hostname from the lookup, and the hostname the SSL cert is registered to. This script attempts to screenshot with Javascript enabled.  If the website takes longer than 20 seconds to load, it will be skipped
]]

author = "Chris King <raikiasec@gmail.com>"

categories = {"discovery", "safe"}

local shortport = require "shortport"
local stdnse = require "stdnse"
local sslcert = require "sslcert"

portrule = shortport.http

action = function(host, port)
	local result = ""
	local protoc = "http"
	local isSSL = port.version.service_tunnel
	local ret = 0

	ret = os.execute('which wkhtmltoimage 2> /dev/null > /dev/null')
	if not ret then
		os.execute('echo "FATAL ERROR: You must run apt-get install wkhtmltopdf for this script to work"')
		result = "FATAL ERROR: You must run apt-get install wkhtmltopdf for this script to work"
		return stdnse.format_output(true, result)
	end

	os.execute("mkdir screenshots 2> /dev/null")


	if isSSL == "ssl" or port.number == 443 or port.number == 8443 then
		protoc = "https"
	end
	local filename = "'screenshots/screenshot-" .. host.ip .. ":" .. port.number .. ".png'"
	local wk_args = "--load-error-handling ignore --stop-slow-scripts --disable-plugins --disable-local-file-access --quality 30 --custom-header-propagation --custom-header 'User-Agent' 'Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.3.0' " .. protoc .. "://" .. host.ip .. ":" .. port.number .. " "
	
	local wk_end = " | true\" 2> /dev/null > /dev/null"

	local wk_cmd = "timeout 20 sh -c \"wkhtmltoimage " .. wk_args .. filename .. wk_end
	result = "Screenshot of IP:"
	os.execute('echo "Screenshotting ' .. protoc .. '://' .. host.ip .. ':' .. port.number .. '"')
	ret = os.execute(wk_cmd)
	if not ret then
		result = result .. "\n   Timed out with javascript...trying without js! "
		os.execute('echo "   ! Timeout, trying without Javascript !"')
		os.execute('echo "Screenshotting IP ' .. protoc .. '://' .. host.ip .. ':' .. port.number .. ' without JS"')
		wk_cmd = "timeout 20 sh -c \"wkhtmltoimage -n " .. wk_args .. filename .. wk_end
		ret = os.execute(wk_cmd)
		if ret then
			result = result .. "\n   It worked without javascript!"
			os.execute('echo "   Success!"')
		else
			result = result .. "\n   It still didn't work.  Oh well..."
			os.execute('echo "   ! Timeout still !"')
		end
	else
		result = result .. "\n   It worked!"
		os.execute('echo "   Success!"')
	end

	local name = stdnse.get_hostname(host)
	if name then
		filename = "'screenshots/screenshot-" .. name .. ":" .. port.number .. ".png'"
		result = result .. "\nScreenshot of hostname (" .. name .. ")"
		wk_cmd = "timeout 20 sh -c \"wkhtmltoimage --custom-header 'Host' '" .. name .. "' " .. wk_args .. filename .. wk_end
		os.execute('echo "Screenshotting hostname ' .. protoc .. '://' .. name .. ':' .. port.number .. '"')
		ret = os.execute(wk_cmd)
		if not ret then
			result = result .. "\n   Timed out with javascript...trying without js! "
			os.execute('echo "   ! Timeout, trying without Javascript !"')
			wk_cmd = "timeout 20 sh -c \"wkhtmltoimage --custom-header 'Host' '" .. name .. "' -n " .. wk_args .. filename .. wk_end
			ret = os.execute(wk_cmd)
			if ret then
				result = result .. "\n   It worked without javascript!"
				os.execute('echo "   Success!"')
			else
				result = result .. "\n   It still didn't work.  Oh well..."
				os.execute('echo "   ! Timeout still !"')
			end
		else
			result = result .. "\n   It worked!"
			os.execute('echo "   Success!"')
		end
	end


	if protoc == "https" then
		local status,cert = sslcert.getCertificate(host,port)
		if status and cert.subject["commonName"] then
			result = result .. "\nScreenshot of SSL subject (" .. cert.subject["commonName"] .. ")"
			os.execute('echo "Screenshotting SSL name ' .. protoc .. '://' .. cert.subject["commonName"] .. ':' .. port.number .. '"')
			filename = "'screenshots/screenshot-" .. cert.subject["commonName"] .. ":" .. port.number .. "-" .. host.ip .. ".png'"
			wk_cmd = "timeout 20 sh -c \"wkhtmltoimage --custom-header 'Host' '" .. cert.subject["commonName"] .. "' " .. wk_args .. filename .. wk_end
			ret = os.execute(wk_cmd)
			if not ret then
				result = result .. "\n   Timed out with javascript...trying without js! "
				os.execute('echo "   ! Timeout, trying without Javascript !"')
				wk_cmd = "timeout 20 sh -c \"wkhtmltoimage --custom-header 'Host' '" .. name .. "' -n " .. wk_args .. filename .. wk_end
				ret = os.execute(wk_cmd)
				if ret then
					result = result .. "\n   It worked without javascript!"
					os.execute('echo "   Success!"')
				else
					result = result .. "\n   It still didn't work.  Oh well..."
					os.execute('echo "   ! Timeout still !"')
				end
			else
				result = result .. "\n   It worked!"
				os.execute('echo "   Success!"')
			end
		end
	end

	return stdnse.format_output(true, result)
end

