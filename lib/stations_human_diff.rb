require "shd/diff_analyzer"
require "shd/environment_checker"
require "shd/github_client"
require "shd/logger"
require "shd/report_formatter"
require "shd/utils"
require "shd/version"

module SHD
  CSV_PARAMETERS = {
    headers:  true,
    col_sep:  ';',
    encoding: 'UTF-8',
  }

  REQUIRED_ENV = %w(
    STATIONS_GITHUB_APP_ID
    STATIONS_GITHUB_APP_NAME
    STATIONS_GITHUB_APP_INSTALL_ID
    STATIONS_GITHUB_APP_CLIENT_ID
    STATIONS_GITHUB_APP_CLIENT_SECRET
    STATIONS_GITHUB_APP_WEBHOOK_SECRET
    STATIONS_GITHUB_APP_PRIVATE_KEY_PEM
  )
end
