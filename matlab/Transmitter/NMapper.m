function mapperout = NMapper (  mapperin,  params );

    if ( params.en_bitalloc )
        mapperout = NMapper_sc ( mapperin,  params );
    else
        mapperout = NMapper_simple ( mapperin,  params );
    end
end 
		

