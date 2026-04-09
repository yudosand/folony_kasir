<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\MemberPoint\ListMemberPointsRequest;
use App\Http\Requests\MemberPoint\MutateMemberPointsRequest;
use App\Services\FoloniAppMemberPointService;
use Illuminate\Http\JsonResponse;
use RuntimeException;

class MemberPointController extends ApiController
{
    public function __construct(
        private readonly FoloniAppMemberPointService $foloniAppMemberPointService,
    ) {
    }

    public function index(ListMemberPointsRequest $request): JsonResponse
    {
        try {
            $result = $this->foloniAppMemberPointService->lookupMembers($request->validated());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), [], 503);
        }

        return $this->successResponse('Member points retrieved successfully.', [
            'members' => $result['members'],
            'total_records' => $result['total_records'],
        ]);
    }

    public function mutate(MutateMemberPointsRequest $request): JsonResponse
    {
        try {
            $result = $this->foloniAppMemberPointService->mutatePoints($request->validated());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), [], 503);
        }

        return $this->successResponse(
            $result['message'] !== '' ? $result['message'] : 'Member points updated successfully.',
            [
                'mutation' => [
                    'member_id' => $result['member_id'],
                    'type' => $result['type'],
                    'amount' => $result['amount'],
                    'description' => $result['description'],
                    'provider_response' => $result['raw'],
                ],
            ]
        );
    }
}
