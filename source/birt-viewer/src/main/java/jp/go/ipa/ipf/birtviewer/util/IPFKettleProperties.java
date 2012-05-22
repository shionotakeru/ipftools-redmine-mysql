/**
 *   <Quantitative project management tool.>
 *   Copyright (C) 2012 IPA, Japan.
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package jp.go.ipa.ipf.birtviewer.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;

public class IPFKettleProperties extends Properties {

    protected static Logger log = Logger.getLogger(IPFKettleProperties.class);
    
    private static final long serialVersionUID = 6496314003104553284L;

    private IPFKettleProperties() { }
    
    public static IPFKettleProperties getInstance() throws IOException {
        final IPFKettleProperties prop = new IPFKettleProperties();
        String kettlePropertiesPath = IPFConfig.getInstance().getProperty("kettle.properties.path");
        log.info("kettle.properties.path=" + kettlePropertiesPath);
        File kettleFile = new File(kettlePropertiesPath);
        if ( kettleFile.canRead()) {
            log.info(String.format("use kettle.properties file '%s'.", kettlePropertiesPath));
        } else {
            String defaultKettleFilePath = null;
            InputStream is = null;
            try {
                URL url = IPFConfig.class.getClassLoader().getResource("kettle.properties");
                if (url != null) {
                    defaultKettleFilePath = url.getPath();
                    kettleFile = new File(defaultKettleFilePath);
                }
            } finally {
                IOUtils.closeQuietly(is);
            }
            log.warn(String.format("Unable to read file '%s'.\n use default file '%s'",
                    kettlePropertiesPath,
                    defaultKettleFilePath));
        }
        
        InputStream is = null;
        try {
            is = FileUtils.openInputStream(kettleFile);
            prop.load(is);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            IOUtils.closeQuietly(is);
        }
        return prop;
    }

}
