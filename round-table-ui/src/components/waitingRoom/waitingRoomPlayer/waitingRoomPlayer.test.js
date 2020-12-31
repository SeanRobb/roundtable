import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import WaitingRoomPlayer from './waitingRoomPlayer';

describe('<WaitingRoomPlayer />', () => {
  test('it should mount', () => {
    render(<WaitingRoomPlayer />);
    
    const waitingRoomPlayer = screen.getByTestId('waitingRoomPlayer');

    expect(waitingRoomPlayer).toBeInTheDocument();
  });
});