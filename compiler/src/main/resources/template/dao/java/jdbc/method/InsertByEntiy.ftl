<#macro insertquery>
  final String query = """
  		INSERT INTO ${table.escapedName} (
  		<#assign index=0>
  		<#list insertableProperties as property>
  			<#if index == 0><#assign index=1><#else>,</#if>${property.column.escapedName}
  		</#list>
  		)
  	    VALUES (
  	    <#assign index=0>
  	    <#list insertableProperties as property>
  			<#if index == 0><#if sequenceName?? && table.highestPKIndex == 1>
  			<#list properties as property>
  			    <#if property.column.primaryKeyIndex == 1>nextval('${sequenceName}')</#if>
  			 </#list>
  			 <#else>    ?</#if><#assign index=1><#else>            ,?</#if>
  		</#list>
  	    )
  		""";
</#macro>
<#macro insertqueryprepared>
<#assign index=0>
			<#assign column_index=1>
			<#list insertableProperties as property>
			<#if index == 0>
				<#if sequenceName?? && property.column.primaryKeyIndex == 1>
				<#else>
				preparedStatement.set${getJDBCClassName(property.dataType)}(${column_index},${wrapGet(name?uncap_first,property)});
				<#assign column_index = column_index + 1>
				</#if>
			<#assign index=1>
			<#else>
			preparedStatement.set${getJDBCClassName(property.dataType)}(${column_index},${wrapGet(name?uncap_first,property)});
			<#assign column_index = column_index + 1>
			</#if>
			</#list>
</#macro>
<#if table.tableType == 'TABLE' >
	public final int insert(final ${name} ${name?uncap_first}) throws SQLException  {
        <@insertquery/>

		try (Connection conn = dataSource.getConnection();
             PreparedStatement preparedStatement = conn.prepareStatement(query))
        {
			<@insertqueryprepared/>
			return preparedStatement.executeUpdate();
        }
	}

	public final InsertBuilder insert() {
        return new InsertBuilder(this);
    }

    public static class InsertBuilder {
        private final ${name}Store${orm.daoSuffix} ${name?uncap_first}Store${orm.daoSuffix};

        private ${name} ${name?uncap_first};

        private InsertBuilder(${name}Store${orm.daoSuffix} ${name?uncap_first}Store${orm.daoSuffix}) {
            this.${name?uncap_first}Store${orm.daoSuffix} = ${name?uncap_first}Store${orm.daoSuffix};
        }

        public InsertBuilder value(${name} ${name?uncap_first}) {
            this.${name?uncap_first} = ${name?uncap_first};
            return this;
        }

        public ${name} returning() throws SQLException  {
            ${name} inserted${name} = null ;
            <@insertquery/>

            try (Connection conn = ${name?uncap_first}Store${orm.daoSuffix}.dataSource.getConnection();
                 PreparedStatement preparedStatement = conn.prepareStatement(query<#if table.hasAutoGeneratedPrimaryKey == true>, Statement.RETURN_GENERATED_KEYS</#if>))
            {
                <@insertqueryprepared/>
                if( preparedStatement.executeUpdate() == 1 ) {
                  <#if table.hasAutoGeneratedPrimaryKey == true>
                  ResultSet res = preparedStatement.getGeneratedKeys();
                  while (res.next()) {
                      inserted${name} =  ${name?uncap_first}Store${orm.daoSuffix}.find(${getPrimaryKeysFromRS()});
                  }
                  <#else>
                  inserted${name} =  ${name?uncap_first}Store${orm.daoSuffix}.find(${getPrimaryKeysFromModel(name?uncap_first)});
                  </#if>
              }
            }
            return inserted${name};
        }
    }
	<#assign a=addImportStatement(beanPackage+"."+name)><#assign a=addImportStatement("java.sql.PreparedStatement")><#assign a=addImportStatement("java.sql.Statement")>
</#if>