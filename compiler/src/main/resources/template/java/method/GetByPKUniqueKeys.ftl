<#if table.uniqueConstraintGroupNames?? && table.uniqueConstraintGroupNames?size != 0 >
<#assign a=addImportStatement(beanPackage+"."+name)>
	<#list table.uniqueConstraintGroupNames as uniqueConstraintGroupName>
    public ${name} get${name}By${uniqueConstraintGroupName}(${getUniqueKeysAsParameterString(uniqueConstraintGroupName)}) throws SQLException   {
		HashMap<String,Object> map = new HashMap<String,Object>();
		${getUniqueKeysAsParameterStringNoTypeMap(uniqueConstraintGroupName)}
				return null;
	}
	</#list>
</#if>