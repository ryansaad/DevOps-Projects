#
#    Copyright 2010-2023 the original author or authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# Use Tomcat 9 (Java 17) as the base image
# This automatically gives us a web server to run the WAR file
FROM tomcat:9.0-jdk17

# Remove default apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file that Jenkins already built into the Tomcat webapps folder
COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]