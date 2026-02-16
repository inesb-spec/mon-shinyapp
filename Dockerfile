FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

# Installer shiny (et forcer l'installation)
RUN R -e "install.packages('shiny', repos='https://cloud.r-project.org', dependencies=TRUE)"

WORKDIR /app
COPY . /app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 3838)))"]
