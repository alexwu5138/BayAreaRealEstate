import os
from sqlalchemy import create_engine, text

env_file = '.env'
if os.path.isfile(env_file):
    with open(env_file, 'r') as f:
        for line in f:
            key, value = line.strip().split('=', 1)
            os.environ[key] = value
DATABASE_URL = os.environ.get('DATABASE_URL')


def get_db_engine(db_name=None):
    """
    Get a SQLAlchemy database engine based on the DATABASE_URL environment variable.
    If db_name is provided, the engine will be configured to use that database.
    """
    db_url = DATABASE_URL
    if db_name:
        parts = DATABASE_URL.split('/')
        parts[-1] = db_name
        db_url = '/'.join(parts)
    return create_engine(db_url)


if __name__ == "__main__":
    """
    An example of how to manipulate data
    """
    engine = get_db_engine()
    with engine.connect() as conn:
        pass
    # conn.commit()
    conn.close()


