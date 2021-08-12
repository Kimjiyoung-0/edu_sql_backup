create or replace function tab_column_function(f_user varchar2,f_empname varchar2)
    return varchar2
is
   v_temp_name varchar2(100); -- column_name�� ������ ����
   v_temp_datatype varchar2(100); -- data_type�� ������ ����
   v_temp_leng number; -- data_length�� ������ ����
   v_temp_precision number; -- data_precision�� ������ ����
   v_temp_scale number; -- data_scale�� ������ ����
   v_temp_notnull varchar2(100); --  nullable�� ������ ����
   v_temp_real_leng varchar2(100); -- ������Ÿ�Կ� ���� �ٸ� ���̸� �����ϱ� ���� ����
   v_column varchar2(1000); -- ���ٷ� list�Ͽ� ����ϱ� ���� ����
   v_cnt number; -- count�� ���� ���� 
begin
    --max(rownum)���� ���� ��� �ִ��� ī��Ʈ�Ѵ�.
    select max(rownum)
    into v_cnt
    from all_tab_columns a   
    where a.owner = f_user
    and a.table_name = f_empname;        
    --1���� ���� ������ŭ �ݺ����� ������.
    
    for i in 1..v_cnt
    loop
        v_temp_real_leng := '';

        select 
            column_name,
            data_type,
            nullable,
            data_length,
            data_precision,
            data_scale
        into 
            v_temp_name,
            v_temp_datatype,
            v_temp_notnull,
            v_temp_leng,
            v_temp_precision,
            v_temp_SCALE
        from
            (
            select a.*,rownum as num
            from all_tab_columns a   
            where a.owner = f_user
            and a.table_name = f_empname
            )
        where num =i;
        --i������ ���� �����Ѵ�.
        
        if v_temp_notnull = 'N' then
            v_temp_notnull := 'NOT NULL';
        else
            v_temp_notnull := '';
        end if; 
        --null���� �ƴ��� üũ
        
        if v_temp_precision is not null then
            v_temp_real_leng := v_temp_precision;
        else
            v_temp_real_leng := v_temp_leng;
        end if; 
        --datatype�� ���� �ٸ����� ����ؾ������� v_temp_precision�� null���� Ȯ��
          
        if (v_temp_SCALE is not null) and (v_temp_SCALE > 0) then
            v_temp_real_leng := v_temp_real_leng||','||v_temp_SCALE;
        else
            v_temp_real_leng := v_temp_real_leng||'';
        end if; 
        --v_temp_SCALE�� null���� Ȯ���ϸ鼭, 0���� ū�� üũ
        
        v_temp_real_leng := '('||v_temp_real_leng||')';
        --���Ŀ� �°� ����
        
        if v_temp_datatype = 'DATE' then
         v_temp_real_leng :='';
         end if;
         --DATE Ÿ���� ��� ��¾���
 
        v_column := v_column 
            ||v_temp_name
            ||' '
            ||v_temp_datatype
            ||' '
            ||v_temp_real_leng
            ||' '
            ||v_temp_notnull||',';
    end loop;

    v_column := rtrim(v_column,',');
    --�ǿ����ʿ��� , �ϳ� ����
    return v_column;     
end;