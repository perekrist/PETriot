import pydantic
import aiohttp.web
from typing import Tuple, Optional
import json


class BaseModel(pydantic.BaseModel):
    @classmethod
    async def from_request(
            cls, request: 'aiohttp.web.Request'
    ) -> Tuple[Optional['BaseModel'], Optional[aiohttp.web.Response]]:
        try:
            data = await request.json()
            return cls(**data), None
        except json.JSONDecodeError as e:
            return None, aiohttp.web.json_response({
                'errors': [e.msg],
            })
        except pydantic.ValidationError as e:
            return None, aiohttp.web.json_response({
                'errors': e.json(),
            }, status=400)
