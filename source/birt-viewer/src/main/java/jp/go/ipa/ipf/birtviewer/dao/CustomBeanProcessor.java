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
package jp.go.ipa.ipf.birtviewer.dao;

import java.beans.PropertyDescriptor;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Arrays;

import org.apache.commons.dbutils.BeanProcessor;

/**
 *
 */
public class CustomBeanProcessor extends BeanProcessor {

    @Override
    protected int[] mapColumnsToProperties(ResultSetMetaData rsmd,
            PropertyDescriptor[] props) throws SQLException {
        
        int cols = rsmd.getColumnCount();
        int columnToProperty[] = new int[cols + 1];
        Arrays.fill(columnToProperty, PROPERTY_NOT_FOUND);
        for (int col = 1; col <= cols; col++) {
            String columnName = rsmd.getColumnName(col);
            for (int i = 0; i < props.length; i++) {
                if (equalsColumnProperty(columnName, props[i].getName())) {
                    columnToProperty[col] = i;
                    break;
                }
            }
        }
        return columnToProperty;
    }
    
    private boolean equalsColumnProperty(String colName, String propName) {
        return colName.replaceAll("_", "").equalsIgnoreCase(propName);
    }

}
