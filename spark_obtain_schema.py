"""Class to obtain a full schema of a json database. Useful in conjunction with utilities that 
allow users to subset distributed dataframes using a known schema."""

from datetime import datetime


class GetDistributedSchema:

    s3_base = 's3n://path/to/parquet'

    def _add_zero(self, integer):
        """
        Add a zero and convert date/time to string for s3 path (if needed).
        :param integer: Integer day or month from datetime (could be single digit).
        :return: A strong consisting of a digit and a zero flag, if needed.
        """
        if integer < 10:
            return '0'+str(integer)
        else:
            return str(integer)

    def get_schema(self, sc, SQLContext):
        """
        Main function to obtain a full schema.
        """
        now = datetime.now()
        now = map(self._add_zero, [now.year, now.month, now.day, now.hour])
        now = '/'.join( [i for i in now] )
        now = '/'.join( [self.s3_base, now, '*'] )
        sql = SQLContext(sc)
        schema = sql.read.json(now)
        schema = schema.schema
        return schema